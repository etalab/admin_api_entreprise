require 'sitemap_generator'

RSpec.describe 'sitemap tasks', type: :rake do
  it 'does not raise error' do
    expect { SitemapGenerator::Interpreter.run(verbose: false) }.not_to raise_error
  end
end
