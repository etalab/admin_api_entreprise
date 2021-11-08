module JwtAPIEntreprise::Operation
  class CreateMagicLink < Trailblazer::Operation
    step Model(JwtAPIEntreprise, :find_by),
      Output(:failure) => End(:not_found)
    step Policy::Pundit(JwtAPIEntreprisePolicy, :magic_link?),
      Output(:failure) => End(:unauthorized)
    step self::Contract::Validate(constant: JwtAPIEntreprise::Contract::CreateMagicLink.new),
      Output(:failure) => End(:invalid_params), fail_fast: true
    step :generate_magic_link_token
    step :send_magic_link

    def generate_magic_link_token(ctx, model:, **)
      model.generate_magic_link_token
    end

    def send_magic_link(ctx, model:, params:, **)
      JwtAPIEntrepriseMailer.magic_link(params[:email], model).deliver_later
    end
  end
end
