class CasUsage
  include ActiveModel::Model

  attr_accessor :name,
    :introduction,
    :role,
    :user_types,
    :comments_endpoints,
    :use_case_examples,
    :list_api,
    :users,
    :request_access,
    :cas_usage_key

  def self.all
    build_all_from_yaml
  end

  def self.find(cas_usage_key)
    build_from_yaml(cas_usage_key)
  end

  def self.build_all_from_yaml
    I18n.t('api_entreprise.cas_usages_entries').map do |cas_usage_key, _entry|
      build_from_yaml(cas_usage_key)
    end
  end

  def self.build_from_yaml(cas_usage_key)
    entry = I18n.t("api_entreprise.cas_usages_entries.#{cas_usage_key}")
    new(
      name: entry[:name],
      introduction: entry[:introduction],
      role: entry[:role],
      user_types: entry[:user_types],
      comments_endpoints: entry[:comments_endpoints],
      use_case_examples: entry[:use_case_examples],
      list_api: entry[:list_api],
      users: entry[:users],
      request_access: entry[:request_access],
      cas_usage_key:
    )
  end
end
