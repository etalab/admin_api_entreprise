module JwtAPIEntreprise::Operation
  class RetrieveFromMagicLink < Trailblazer::Operation
    step :magic_token?
    step :retrieve_from_magic_link_token
    step :magic_link_token_valid?

    def magic_token?(ctx, params:, **)
      ctx[:magic_token] = params[:token]
    end

    def retrieve_from_magic_link_token(ctx, magic_token:, **)
      ctx[:jwt] = JwtAPIEntreprise.find_by(magic_link_token: magic_token)
    end

    def magic_link_token_valid?(ctx, jwt:, **)
      expiration_time = jwt.magic_link_issuance_date + 4.hours
      Time.zone.now < expiration_time
    end
  end
end
