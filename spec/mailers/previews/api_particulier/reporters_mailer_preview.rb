class APIParticulier::ReportersMailerPreview < ActionMailer::Preview
  %w[
    submit
    approve
  ].each do |event|
    define_method(event) do
      APIParticulier::ReportersMailer.with(group:).send(event)
    end
  end

  private

  def group
    'cnaf'
  end
end
