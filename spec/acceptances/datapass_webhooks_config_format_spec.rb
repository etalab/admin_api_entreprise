require 'rails_helper'
require 'yaml'

RSpec.describe 'Datapass webhook config format', type: :acceptance do
  let(:file) { Rails.root.join('./config/datapass_webhooks.yml') }
  let(:dummy_authorization_request) { create(:authorization_request, :with_contacts) }

  it 'is a valid file' do
    expect {
      YAML.load_file(file)
    }.not_to raise_error
  end

  it 'has valid format for each event' do
    yaml_config = YAML.load_file(file)

    %w[
      development
      test
      production
      sandbox
    ].each do |env|
      yaml_config[env].each do |event, config|
        next if config['emails'].blank?

        expect(config['emails']).to be_a(Array), "[#{env}] #{event} has an emails key which is not an array"

        config['emails'].each_with_index do |email_config, index|
          expect(email_config['id']).to be_present, "[#{env}] #{event} emails ##{index + 1} has no id key"

          if email_config['when'].present?
            date = Chronic.parse(email_config['when'])

            expect(date).to be_present, "[#{env}] #{event} emails ##{index + 1} has an invalid date for 'when', which is not parsable: #{email_config['when']}"
            expect(date).to be_future, "[#{env}] #{event} emails ##{index + 1} has an invalid date for 'when', which is not in the future: #{email_config['when']}"
          end

          %w[to cc].each do |kind|
            next if email_config[kind].blank?

            expect(email_config[kind]).to be_an_instance_of(Array), "[#{env}] #{event} emails ##{index + 1} has an invalid '#{kind}': not an array"

            email_config[kind].each do |to_recipient|
              contact = to_recipient.split('.').reduce(OpenStruct.new(authorization_request: dummy_authorization_request)) do |object, method|
                object = object.public_send(method)
              end

              expect(contact).to respond_to(:email)
              expect(contact).to respond_to(:full_name)
            end
          end

          next if email_config['condition_on_authorization'].blank?
          next if %w[development test].include?(env)

          method = email_config['condition_on_authorization']
          expect(AuthorizationRequestConditionFacade).to be_method_defined(method), "[#{env}] #{event} emails ##{index + 1} condition_on_authorization: AuthorizationRequestConditionFacade##{method} is not defined"

          result = AuthorizationRequestConditionFacade.new(dummy_authorization_request).public_send(method)
          expect(result).to be_an_instance_of(TrueClass).or(be_an_instance_of(FalseClass)), "[#{env}] #{event} emails ##{index + 1} condition_on_authorization: AuthorizationRequestConditionFacade##{method} does not returns a boolean"
        end
      end
    end
  end
end
