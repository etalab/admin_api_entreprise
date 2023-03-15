module AbstractAPIClass
  extend ActiveSupport::Concern

  def api
    self.class.api
  end

  class_methods do
    def api
      name.underscore.split('/')[-2]
    end
  end
end
