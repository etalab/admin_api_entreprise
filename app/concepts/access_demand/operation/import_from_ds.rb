module AccessDemand::Operation
  class ImportFromDs < Trailblazer::Operation
    step :init_csv_reader
    step :import_users_siret
    step :manual_updates


    def init_csv_reader(ctx, **)
      ctx[:csv_reader] = CsvReader.new('./csv_dumps/ds-export.csv')
    end

    def import_users_siret(ctx, csv_reader:, **)
      csv_reader.line_by_line do |line|
        puts line['Email']
        next if ignore_request?(line)

        email_from_dump = line['Email'].downcase
        user = User.find_by_email!(real_email(email_from_dump))
        next if user_context_equals_siret?(user)

        user.update(context: line['Numéro de SIRET'])
      end
    end

    # Manualy updating the few remaning entries
    def manual_updates(ctx, **)
      User.find('91d31930-890e-485f-968d-758db60df82e').update(context: '54585044800030')
      User.find('fe15a4e2-87cf-4e35-b8b1-20f1957dda72').update(context: '43196025100061')
      User.find('b609f239-1078-434c-a403-feee97c1004a').update(context: '79004395400029')
    end

    private

    def ignore_request?(line)
      return true if line['État du dossier'] != 'Accepté'
      return true if line['ID'] == '377645' # Test de V.M.
      return true if line['ID'] == '394171' # J'ai retrouvé le jeton grâce au siret 24400067500151, le user a été supprimé...
      return true if line['ID'] == '466577' # Aucune entrée en base correspondante pour cette demande...
      return true if line['ID'] == '336048' # User deleted as he now uses ATEXO

      false
    end

    def user_context_equals_siret?(user)
      user.context =~ /\d{14}/
    end

    # Manualy matching email used for dashboard account from DS request
    def real_email(email)
      DSEmailHash[email] || email
    end
  end
end
