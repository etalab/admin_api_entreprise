module AbstractAPIClass
  extend ActiveSupport::Concern

  delegate :api, to: :class

  class_methods do
    def api
      name.underscore.split('/')[-2]
    end
  end
end
