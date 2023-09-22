class RevokingNotUsedAuthorizationRequestWithNoDatapass < ActiveRecord::Migration[7.0]
  USED_AR_ID_WITH_NO_DATAPASS = %w[
    14003128-5eed-4087-b04c-b4c6e5962040
    61da2c91-1c49-4ac2-8012-efabac411b44
    9991734e-317b-4110-8a38-aad86edce633
    aec4345f-155a-47c7-9bc8-6acd671e945d
    f7fe5da2-48cc-4675-8fad-25cba4ef0f33
  ]

  def up
    not_used_ars_with_no_datapass = AuthorizationRequest
      .where(external_id: nil)
      .where.not(id: USED_AR_ID_WITH_NO_DATAPASS)

    not_used_ars_with_no_datapass.find_each do |authorization_request|
      authorization_request.blacklist!
    end
  end

  def down
    not_used_ars_with_no_datapass = AuthorizationRequest
      .where(external_id: nil)
      .where(status: 'blacklisted')
      .where.not(id: USED_AR_ID_WITH_NO_DATAPASS)

    not_used_ars_with_no_datapass.find_each do |authorization_request|
      token&.update!(blacklisted: false)

      update!(status: 'active')
    end
  end
end
