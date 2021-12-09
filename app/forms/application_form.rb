class ApplicationForm < Reform::Form
  def update(params)
    save if validate(params)
  end
end
