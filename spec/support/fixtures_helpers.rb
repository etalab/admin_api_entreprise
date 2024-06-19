module FixturesHelpers
  def fixture_exists?(path)
    Rails.root.join('spec', 'fixtures', path).exist?
  end

  def open_fixture(path)
    File.open(File.join(File.dirname(__FILE__), '..', 'fixtures', path))
  end

  def read_fixture(path)
    open_fixture(path).read
  end

  def read_json_fixture(path)
    JSON.parse(open_fixture(path).read)
  end
end
