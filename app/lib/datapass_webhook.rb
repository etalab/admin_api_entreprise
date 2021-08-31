class DatapassWebhook
  def self.call(...)
    OpenStruct.new(token_id: rand(9001).to_s)
  end
end
