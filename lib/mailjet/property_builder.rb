# frozen_string_literal: true

module Mailjet
  class PropertyBuilder
    attr_reader :user, :types

    def initialize(user)
      raise ::TypeError, user.class.inspect unless user.is_a?(::User)

      @user = user
      @types = user.contacts.unscoped.pluck(:contact_type)
    end

    def call
      {
        contact_demandeur:  types.include?('other'),
        contact_métier:     types.include?('admin'),
        contact_technique:  types.include?('tech'),
        techlettre:         types.include?('tech'),
        infolettre:         true,
        origine:            'dashboard'
      }
    end
  end
end
