require 'rake'

module UsersFactory
  def self.inactive_user
    params = {
      email: 'in@ctive.user',
      oauth_api_gouv_id: 1234,
      context: 'testing confirmation',
      cgu_agreement_date: '2019-12-26T14:38:45.490Z'
    }
    operation_result = User::Operation::Create.call(params: params)
    operation_result[:model]
  end

  def self.confirmed_user
    unconfirmed_user = inactive_user
    params = { confirmation_token: unconfirmed_user.confirmation_token,
               password: 'couCOU123',
               password_confirmation: 'couCOU123'
    }
    operation_result = User::Operation::Confirm.call(params: params)
    operation_result[:model]
  end

  def self.admin
    AdminApientreprise::Application.load_tasks
    Rake::Task['create_admin'].invoke
    User.last
  end
end
