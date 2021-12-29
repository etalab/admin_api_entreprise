class ApplicationInteractor
  include Interactor

  def fail!(message, level, attributes={})
    if attributes.any?
      Sentry.set_context(
        'Error context',
        attributes
      )
    end

    Sentry.capture_message(
      message,
      level: level,
    )

    context.fail!(message: message, attributes: attributes)
  end
end
