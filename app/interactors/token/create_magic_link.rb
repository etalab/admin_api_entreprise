class Token::CreateMagicLink < ApplicationInteractor
  def call
    fail!('invalid_email', 'warn', errors) unless valid_email?
    create_magic_link
    send_magic_link_email
  end

  private

  def valid_email?
    context.email_target_user = User.new(email: context.email)
    context.email_target_user.valid?
  end

  def errors
    context.email_target_user.errors.to_hash
  end

  def create_magic_link
    context.token.generate_magic_link_token
  end

  def send_magic_link_email
    JwtAPIEntrepriseMailer.magic_link(context.email, context.token).deliver_later
  end
end
