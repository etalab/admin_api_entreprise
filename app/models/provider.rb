class Provider
  include ActiveModel::Model

  attr_accessor :uid, :name, :external_link

  def self.all
    I18n.t('providers').map { |entry| new(entry) }
  end

  def self.filter_by_uid(uids)
    all.select do |provider|
      uids.include?(provider.uid)
    end
  end
end
