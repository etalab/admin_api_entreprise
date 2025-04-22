class MigrateTokensScopesToAPIParticulierV3 < ActiveRecord::Migration[8.0]
  def up
    # For France Travail: add 'pole_emploi_identifiant' if any of the related scopes exists
    safety_assured do
      execute <<-SQL
        UPDATE tokens
        SET scopes = (
          SELECT jsonb_agg(DISTINCT value)
          FROM (
            SELECT jsonb_array_elements_text(tokens.scopes) AS value
            UNION
            SELECT 'pole_emploi_identifiant'
          ) s
        )
        WHERE EXISTS (
          SELECT 1
          FROM jsonb_array_elements_text(tokens.scopes) AS scope
          WHERE scope IN ('pole_emploi_identite', 'pole_emploi_contact', 'pole_emploi_adresse', 'pole_emploi_inscription')
        )
        AND NOT EXISTS (
          SELECT 1
          FROM jsonb_array_elements_text(tokens.scopes) AS scope
          WHERE scope = 'pole_emploi_identifiant'
        );
      SQL

      # For MEN: add 'men_statut_identite', 'men_statut_etablissement' and 'men_statut_module_elementaire_formation'
      execute <<-SQL
        UPDATE tokens
        SET scopes = (
          SELECT jsonb_agg(DISTINCT value)
          FROM (
            SELECT jsonb_array_elements_text(tokens.scopes) AS value
            UNION
            SELECT 'men_statut_identite'
            UNION
            SELECT 'men_statut_etablissement'
            UNION
            SELECT 'men_statut_module_elementaire_formation'
          ) s
        )
        WHERE EXISTS (
          SELECT 1
          FROM jsonb_array_elements_text(tokens.scopes) AS scope
          WHERE scope IN ('men_statut_scolarite', 'men_statut_boursier', 'men_echelon_bourse')
        );
      SQL
    end
  end

  def down
    safety_assured do
      # Revert France Travail: remove 'pole_emploi_identifiant'
      execute <<-SQL
        UPDATE tokens
        SET scopes = (
          SELECT jsonb_agg(value)
          FROM (
            SELECT value
            FROM jsonb_array_elements_text(tokens.scopes) AS value
            WHERE value <> 'pole_emploi_identifiant'
          ) s
        )
        WHERE EXISTS (
          SELECT 1
          FROM jsonb_array_elements_text(tokens.scopes) AS scope
          WHERE scope = 'pole_emploi_identifiant'
        );
      SQL

      # Revert MEN: remove the MEN-related scopes
      execute <<-SQL
        UPDATE tokens
        SET scopes = (
          SELECT jsonb_agg(value)
          FROM (
            SELECT value
            FROM jsonb_array_elements_text(tokens.scopes) AS value
            WHERE value NOT IN ('men_statut_identite', 'men_statut_etablissement', 'men_statut_module_elementaire_formation')
          ) s
        )
        WHERE EXISTS (
          SELECT 1
          FROM jsonb_array_elements_text(tokens.scopes) AS scope
          WHERE scope IN ('men_statut_identite', 'men_statut_etablissement', 'men_statut_module_elementaire_formation')
        );
      SQL
    end
  end
end
