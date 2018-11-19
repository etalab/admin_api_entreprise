class Role
  class DBSeed < Trailblazer::Operation
    ROLES_SEED = [
      { name: 'Attestation AGEFIPH',    code: 'attestations_agefiph' },
      { name: 'Attestation Fiscale',    code: 'attestations_fiscales' },
      { name: 'Attestation Sociale',    code: 'attestations_sociales' },
      { name: 'Certificat CNETP',       code: 'certificat_cnetp' },
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
      { name: 'Bilans Entreprises BDF', code: 'bilans_entreprise_bdf' }
    ]

    step ->(options, **) { options[:log] = [] }
    success :seed!

    def seed!(options, log:, **)
      ROLES_SEED.each do |role|
        result = Role::Create.call(params: role)
        if result.success?
          log << "Role created : name \"#{role[:name]}\", code \"#{role[:code]}\""
        else
          log << "Warning role already exists : name \"#{role[:name]}\", code \"#{role[:code]}\""
        end
      end
    end
  end
end
