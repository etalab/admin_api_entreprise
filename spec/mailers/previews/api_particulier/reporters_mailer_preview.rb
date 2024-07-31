class APIParticulier::ReportersMailerPreview < ActionMailer::Preview
  %w[
    submit
    approve
  ].each do |event|
    define_method(event) do
      APIParticulier::ReportersMailer.with(groups:).send(event)
    end
  end

  private

  def groups
    %w[cnaf men]
  end
end
