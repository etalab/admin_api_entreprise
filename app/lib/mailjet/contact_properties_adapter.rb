# frozen_string_literal: true

module Mailjet
  class ContactPropertiesAdapter
    attr_reader :user, :roles, :types

    def initialize(user)
      @user = user
      @roles = user.roles.map(&:code)
      @types = user.contacts.map(&:contact_type)
    end

    def call
      {
        contact_demandeur:  types.include?('other'),
        contact_métier:     types.include?('admin'),
        contact_technique:  types.include?('tech'),
        techlettre:         types.include?('tech'),
        infolettre:         true,
        origine:            'dashboard'
      }.merge(**role_properties)
    end

    private

    def role_properties
      available_role_codes.inject({}) do |properties, role|
        properties.merge("role_#{role}".to_sym => roles.include?(role))
      end
    end

    def available_role_codes
      ::Role.available.map(&:code)
    end
  end
end
