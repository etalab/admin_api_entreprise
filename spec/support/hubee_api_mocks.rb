module HubEEAPIMocks
  def hubee_organization_payload(siret: '13002526500013', code_commune: '75017')
    {
      'country' => 'France',
      'code' => 'DINUM',
      'postalCode' => '75007',
      'type' => 'SI',
      'companyRegister' => siret,
      'createDateTime' => '2021-05-20T15:59:02.569+00:00',
      'branchCode' => code_commune,
      'phoneNumber' => '0000000000',
      'name' => 'DIRECTION INTERMINISTERIELLE DU NUMERIQUE',
      'updateDateTime' => '2022-01-27T19:42:07.386+00:00',
      'email' => 'datapass@yopmail.com',
      'territory' => 'PARIS 7',
      'status' => 'Actif'
    }
  end

  def hubee_subscription_payload(authorization_request:, organization_payload: hubee_organization_payload, process_code: 'TEST')
    {
      'id' => SecureRandom.uuid,
      'datapassId' => authorization_request.external_id.to_i,
      'notificationFrequency' => 'unitaire',
      'processCode' => process_code,
      'email' => authorization_request.demandeur.email,
      'localAdministrator' => {
        'email' => authorization_request.demandeur.email
      },
      'status' => 'Actif',
      'subscriber' => {
        'branchCode' => organization_payload['branchCode'],
        'companyRegister' => organization_payload['companyRegister'],
        'type' => 'SI'
      },
      'creationDateTime' => '2024-06-24T16:01:27.142+00:00',
      'updateDateTime' => '2024-06-24T16:01:27+0000'
    }
  end
end
