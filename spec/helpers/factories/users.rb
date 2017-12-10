module UsersFactory
  def self.inactive_user
    params = { email: 'in@ctive.user', context: 'testing confirmation' }
    operation_result = User::Create.call(params)
    operation_result['model']
  end
end
