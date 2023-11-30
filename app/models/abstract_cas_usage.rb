class AbstractCasUsage
  include ActiveModel::Model
  include AbstractAPIClass

  CAS_USAGE_KEYS = %i[
    uid
    name
    introduction
    role
    user_types
    comments_endpoints
    use_case_examples
    list_api
    users
    request_access
    endpoints
    endpoints_optional
    endpoints_forbidden
  ].freeze

  attr_accessor(*CAS_USAGE_KEYS)

  def self.all
    backend.map do |uid, entry|
      build_from_yaml(uid, entry)
    end
  end

  def self.find(uid)
    cas_usage = all.find { |item| item.uid == uid }

    raise not_found(uid) if cas_usage.nil?

    cas_usage
  end

  def self.not_found(uid)
    ActiveRecord::RecordNotFound.new("CasUsage '#{uid}' does not exist")
  end

  def self.build_from_yaml(uid, entry)
    new(
      entry.slice(
        *CAS_USAGE_KEYS
      ).merge(
        uid: uid.to_s
      )
    )
  end

  def self.backend
    I18n.t("#{api}.cas_usages_entries", raise: true)
  end
end
