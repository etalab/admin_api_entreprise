class MonitoringService
  include Singleton

  def track(event, level:, context: {})
    Sentry.set_context('Extra context', context) unless context.empty?

    Sentry.capture_message(event, level: level)
  end
end
