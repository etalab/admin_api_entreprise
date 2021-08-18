class DatapassWebhook::ExtractMailjetVariables < ApplicationInteractor
  def call
    context.mailjet_variables = build_common_mailjet_variables

    add_instructors_variables if event_from_instructor?
    add_token_roles if token_present?
  end

  private

  def build_common_mailjet_variables
    {
      'authorization_request_id'          => authorization_request.external_id,
      'authorization_request_intitule'    => authorization_request.intitule,
      'authorization_request_description' => authorization_request.description,
    }
  end

  def add_instructors_variables
    instructor_payload = latest_authorization_request_event['user']

    context.mailjet_variables['instructor_first_name'] = instructor_payload['given_name']
    context.mailjet_variables['instructor_last_name'] = instructor_payload['family_name']
  end

  def latest_authorization_request_event
    context.data['pass']['events'].sort do |event1, event2|
      DateTime.parse(event2['created_at']).to_i <=> DateTime.parse(event1['created_at']).to_i
    end.first
  end

  def event_from_instructor?
    events_from_instructor.include?(context.event)
  end

  def add_token_roles
    context.mailjet_variables['token_roles'] ||= {}

    available_roles.each do |role|
      context.mailjet_variables['token_roles']["role_#{role}"] = token_roles.include?(role)
    end
  end

  def token_present?
    authorization_request.jwt_api_entreprise.present?
  end

  def token_roles
    @token_roles ||= authorization_request.jwt_api_entreprise.roles.pluck(:code)
  end

  def events_from_instructor
    %w[
      refuse_application
      review_application
      validate_application
      notify
    ].freeze
  end

  def authorization_request
    context.authorization_request
  end

  def available_roles
    ::Role.where.not(code: excluded_roles).pluck(:code)
  end

  def excluded_roles
    %w[
      uptime
    ].freeze
  end
end
