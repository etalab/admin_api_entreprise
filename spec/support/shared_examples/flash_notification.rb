RSpec.shared_examples 'display alert' do |kind|
  it 'displays an alert' do
    subject

    expect(page).to have_css(".fr-alert--#{kind}")
    expect(page).to have_no_text('translation missing')
  end
end
