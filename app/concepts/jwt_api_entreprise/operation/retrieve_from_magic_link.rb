module JwtAPIEntreprise::Operation
  class RetrieveFromMagicLink < Trailblazer::Operation
    step :retrieve_from_magic_link_token
    step :magic_link_token_valid?

    def retrieve_from_magic_link_token(ctx, params:, **)
      ctx[:jwt] = JwtAPIEntreprise.find_by_magic_link_token(params[:token])
    end

    def magic_link_token_valid?(ctx, jwt:, **)
      expiration_time = jwt.magic_link_issuance_date + 4.hours
      Time.zone.now < expiration_time
    end
  end
end
