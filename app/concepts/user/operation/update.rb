class User
  module Operation
    class Update < Trailblazer::Operation
      step Model(User, :find_by)
      fail ->(options, params:, **) { options[:errors] = "User with id `#{params[:id]}` does not exist." }

      step self::Contract::Build(constant: User::Contract::Update)
      step self::Contract::Validate()
      step self::Contract::Persist()
    end
  end
end
