RSpec.shared_examples :display_alert do |kind|
  it 'displays an alert' do
    subject

    expect(page).to have_css(".fr-alert--#{kind}")
  end
end
