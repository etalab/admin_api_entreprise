class SiadeClientError < StandardError
  attr_reader :code

  def initialize(code, msg = 'Error with Siade client')
    @code = code

    super(msg)
  end
end
