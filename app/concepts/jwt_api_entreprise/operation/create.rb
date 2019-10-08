module JwtApiEntreprise::Operation
  class Create < Trailblazer::Operation
    step Model(JwtApiEntreprise, :new)
    step self::Contract::Build(constant: JwtApiEntreprise::Contract::Create)
    step self::Contract::Validate()
    step self::Contract::Persist()
    step :set_token_defaults

    def set_token_defaults(options, model:, **)
      model.update(
        iat: Time.zone.now.to_i,
        version: '1.0',
        exp: 18.months.from_now.to_i
      )
    end
  end
end
