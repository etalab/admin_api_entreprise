module AccessDemand::Operation
  class ImportFromSignup < Trailblazer::Operation
    step :init_csv_reader
    step :import_access_request_id


    def init_csv_reader(ctx, **)
      ctx[:csv_reader] = CsvReader.new('./csv_dumps/signup-export.csv', ';')
    end

    def import_access_request_id(ctx, csv_reader:, **)
      csv_reader.line_by_line do |line|
        next if ignore_request?(line)

        email_from_export = line['email']
        user = User.find_by_email!(real_email(email_from_export))

        if line['signup_id'] == '1173' # This is a renewal request, setting the authorization_request_id to the right JWT manually
          JwtApiEntreprise.find('e1ff50f2-426d-49a3-b1c9-04a5427d8ce7').update(authorization_request_id: '1173')
        elsif user.jwt_api_entreprise.count == 1
          user.jwt_api_entreprise.first.update(authorization_request_id: line['signup_id'])
        else
          raise StandardError.new('Moults tokens')
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
