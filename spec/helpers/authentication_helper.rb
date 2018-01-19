module AuthenticationHelper
  def set_authentication_token
    request.headers['Authorization'] = 'Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1aWQiOiI0YzYzYzlkOS0xOGRjLTRhNjMtYTU1NS1kZTg3ZjY0M2YyYzAifQ.l42ieWm397uZCuI6GeD1r9uf7D-k8u3VoBDsP9RRip0'
  end
end
