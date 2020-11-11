module Role::Operation
  class DBSeed < Trailblazer::Operation
    step :init_roles_seed
    step ->(options, **) { options[:log] = [] }
    step :seed!

    def seed!(options, roles_seed:, log:, **)
      roles_seed.each do |role|
        result = Role::Operation::Create.call(params: role)
        if result.success?
          log << "Role created : name \"#{role[:name]}\", code \"#{role[:code]}\""
        else
          log << "Warning role already exists : name \"#{role[:name]}\", code \"#{role[:code]}\""
        end
      end
    end

    def init_roles_seed(ctx, roles_seed: nil, **)
      if roles_seed.nil?
        ctx[:roles_seed] = [
          { name: 'Attestation AGEFIPH',    code: 'attestations_agefiph' },
          { name: 'Attestation Fiscale',    code: 'attestations_fiscales' },
          { name: 'Attestation Sociale',    code: 'attestations_sociales' },
          { name: 'Certificat CNETP',       code: 'certificat_cnetp' },
          { name: 'Certificat RGE (ADEME)', code: 'certificat_rge_ademe' },
          { name: 'Association',            code: 'associations' },
          { name: 'Certificat OPQIBI',      code: 'certificat_opqibi' },
          { name: 'Document association',   code: 'documents_association' },
          { name: 'INSEE Etablissement',    code: 'etablissements' },
          { name: 'INSEE Entreprise',       code: 'entreprises' },
          { name: 'Extrait INPI',           code: 'extrait_court_inpi' },
          { name: 'Extrait RCS',            code: 'extraits_rcs' },
          { name: 'Exercice',               code: 'exercices' },
          { name: 'Liasse fiscale',         code: 'liasse_fiscale' },
          { name: 'Carte Pro FNTP',         code: 'fntp_carte_pro' },
          { name: 'Certificat Qualibat',    code: 'qualibat' },
          { name: 'Certificat PROBTP',      code: 'probtp' },
          { name: 'Cotisation MSA',         code: 'msa_cotisations' },
          { name: 'Bilans Entreprises BDF', code: 'bilans_entreprise_bdf' },
          { name: 'Actes INPI',             code: 'actes_inpi' },
          { name: 'Bilans INPI',            code: 'bilans_inpi' },
          { name: 'UptimeRobot',            code: 'uptime' },
        ]
      end
      ctx[:roles_seed]
    end
  end
end
