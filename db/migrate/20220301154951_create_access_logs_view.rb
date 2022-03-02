class CreateAccessLogsView < ActiveRecord::Migration[6.1]
  def self.up
    execute <<-SQL
      CREATE VIEW access_logs_view AS
      SELECT
        timestamp,
        action,
        api_version,
        host,
        method,
        path,
        route,
        controller,
        duration,
        status,
        ip,
        source,
        jwt_api_entreprise_id,
        params -> 'siren' as param_siren,
        params -> 'siret' as param_siret,
        params -> 'id' as param_id,
        params -> 'object' as param_object,
        params -> 'context' as param_context,
        params -> 'recipient' as param_recipient,
        params -> 'mois' as param_mois,
        params -> 'annee' as param_annee,
        params -> 'non_diffusables' as param_non_diffusables
      FROM access_logs;
    SQL
  end
  def self.down
    execute <<-SQL
      DROP VIEW access_logs_view
    SQL
  end
end
