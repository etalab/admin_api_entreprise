module ResponseHelper
  def response_json
    JSON.parse(response.body, symbolize_names: true)
  end
end
