RSpec.shared_examples 'display alert' do |kind|
  it 'displays an alert' do
    subject

    expect(page).to have_css(".fr-alert--#{kind}")
    expect(page).not_to have_text('translation missing')
  end
end
