module AccessDemand::Operation
  class ImportFromSignup < Trailblazer::Operation
    step :init_csv_reader
    step :import_access_request_id


    def init_csv_reader(ctx, **)
      ctx[:csv_reader] = CsvReader.new('./csv_dumps/signup-export.csv', ';')
    end

    def import_access_request_id(ctx, csv_reader:, **)
      csv_reader.line_by_line do |line|
        puts line['email']
        next if ignore_request?(line)

        email_from_export = line['email']
        user = User.find_by_email!(real_email(email_from_export))

        if line['signup_id'] == '1173' # This is a renewal request, setting the authorization_request_id to the right JWT manually
          JwtApiEntreprise.find('e1ff50f2-426d-49a3-b1c9-04a5427d8ce7').update(authorization_request_id: '1173')
        elsif line['signup_id'] == '1369'
          JwtApiEntreprise.find('e3b337a0-ffa0-4ead-9088-d3483066817a').update(authorization_request_id: '1369')
        elsif line['signup_id'] == '1296'
          JwtApiEntreprise.find('3f47617b-b34e-44e7-9918-1e4b3b9b044d').update(authorization_request_id: '1296')
        elsif line['signup_id'] == '1297'
          JwtApiEntreprise.find('030f23d1-ca78-4f39-9186-827a3f0452ff').update(authorization_request_id: '1297')
        elsif line['signup_id'] == '1295'
          JwtApiEntreprise.find('1333b263-1e2a-40af-8cbc-540d367c705f').update(authorization_request_id: '1295')
        elsif line['signup_id'] == '1415'
          JwtApiEntreprise.find('3ee9f0fe-b67d-432e-91d2-e01b4263a7cb').update(authorization_request_id: '1415')
        elsif line['signup_id'] == '1414'
          JwtApiEntreprise.find('b591b8a3-ad15-4551-b13e-93bdc5f98f35').update(authorization_request_id: '1414')
        elsif line['signup_id'] == '1413'
          JwtApiEntreprise.find('03015756-7b4f-4f6f-bced-4c3e43fb6c7f').update(authorization_request_id: '1413')
        elsif line['signup_id'] == '1371'
          JwtApiEntreprise.find('2d5325f0-b8ac-421d-a718-2347d79e6dd9').update(authorization_request_id: '1371')
        elsif line['signup_id'] == '1273'
          JwtApiEntreprise.find('496868dc-53c1-46cc-8cf1-a9288dff453e').update(authorization_request_id: '1273')
        elsif line['signup_id'] == '1445'
          JwtApiEntreprise.find('345da886-21cd-4baa-be05-b1fc819a3500').update(authorization_request_id: '1445')
        elsif line['signup_id'] == '1444'
          JwtApiEntreprise.find('1c01ee21-72a1-4edb-bf03-bbdfad5e0ee6').update(authorization_request_id: '1444')
        elsif user.jwt_api_entreprise.count == 1
          user.jwt_api_entreprise.first.update(authorization_request_id: line['signup_id'])
        else
          raise StandardError.new("Moults tokens : #{line['signup_id']}")
        end
      end
    end

    private

    def real_email(email)
      SignupEmailHash[email] || email
    end

    def ignore_request?(line)
      return true if line['signup_id'] == '848' # Aucune entrée correspondante trouvée en base...

      false
    end
  end
end
