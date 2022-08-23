constraints(APIParticulierDomainConstraint.new) do
  scope module: :api_particulier do
    get '/', to: 'pages#home'
  end
end
