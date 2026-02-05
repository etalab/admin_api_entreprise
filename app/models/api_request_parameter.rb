class APIRequestParameter
  attr_reader :name, :required, :location

  def initialize(name:, required: false, location: nil)
    @name = name
    @required = required
    @location = location
  end

  def label
    input_name
  end

  def input_name
    name.delete_suffix('[]')
  end

  def array?
    name.end_with?('[]')
  end
end
