class User
  module Operation
    class Update < Trailblazer::Operation
      step Model(User, :find_by)
      fail ->(options, params:, **) { options[:errors] = "User with id `#{params[:id]}` does not exist." }, fail_fast: true

      step self::Contract::Build(constant: User::Contract::Update)
      step self::Contract::Validate()
      fail ->(ctx, **) { ctx[:errors] = ctx['result.contract.default'].errors.messages }
      step self::Contract::Persist()
    end
  end
end
