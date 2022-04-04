class ApplicationInteractor
  include Interactor

  def fail!(message, level, attributes = {})
    if attributes.any?
      Sentry.set_context(
        'Error context',
        attributes
      )
    end

    Sentry.capture_message(
      message,
      level:
    )

    context.fail!(message:, attributes:)
  end
end
