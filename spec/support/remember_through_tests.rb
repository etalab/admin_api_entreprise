# rubocop:disable Style/MutableConstant
RSPEC_GLOBAL = {}
# rubocop:enable Style/MutableConstant

def remember_through_tests(variable_name)
  instance_variable_set("@#{variable_name}", RSPEC_GLOBAL[variable_name] || begin
    yield
  end)
  RSPEC_GLOBAL[variable_name] ||= instance_variable_get("@#{variable_name}")
end
