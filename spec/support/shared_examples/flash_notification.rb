RSpec.shared_examples :alert_error do
  it 'displays an error' do
    subject

    expect(page).to have_css('.fr-alert--error')
  end
end

RSpec.shared_examples :alert_success do
  it 'displays an error' do
    subject

    expect(page).to have_css('.fr-alert--success')
  end
end

RSpec.shared_examples :alert_info do
  it 'displays an error' do
    subject

    expect(page).to have_css('.fr-alert--info')
  end
end
