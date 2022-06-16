class MigrateToCrossProductJwt < ActiveRecord::Migration[7.0]
  def up
    up_rename_jwt_api_entreprise_table
    up_rename_role_table
    up_add_column_api
    up_add_column_extra_info
    up_seed_scopes_for_api_particulier

    update_view :access_logs_view, version: 3
  end

  def down
    # exact reverse order as up (except for view)
    down_seed_scopes_for_api_particulier
    down_add_column_extra_info
    down_add_column_api
    down_rename_role_table
    down_rename_jwt_api_entreprise_table

    update_view :access_logs_view, version: 2
  end

  private

  def up_rename_jwt_api_entreprise_table
    rename_table  :jwt_api_entreprises, :tokens
    rename_column :access_logs, :jwt_api_entreprise_id, :token_id
    rename_column :jwt_api_entreprises_roles, :jwt_api_entreprise_id, :token_id
    rename_table  :jwt_api_entreprises_roles, :roles_tokens
  end

  def down_rename_jwt_api_entreprise_table
    rename_table  :roles_tokens, :jwt_api_entreprises_roles
    rename_column :jwt_api_entreprises_roles, :token_id, :jwt_api_entreprise_id
    rename_column :access_logs, :token_id, :jwt_api_entreprise_id
    rename_table  :tokens, :jwt_api_entreprises
  end

  def up_rename_role_table
    rename_table :roles, :scopes
    rename_column :roles_tokens, :role_id, :scope_id
    rename_table :roles_tokens, :scopes_tokens
  end

  def down_rename_role_table
    rename_table :scopes_tokens, :roles_tokens
    rename_column :roles_tokens, :scope_id, :role_id
    rename_table :scopes, :roles
  end

  def up_add_column_api
    add_column :scopes, :api, :text
    Scope.update_all(api: :entreprise)
    change_column_null(:scopes, :api, false)
    change_column_null(:scopes, :code, false)
    change_column_null(:scopes, :name, false)
  end

  def down_add_column_api
    remove_column :scopes, :api
  end

  def up_add_column_extra_info
    add_column :tokens, :extra_info, :json, defaults: {}
  end

  def down_add_column_extra_info
    remove_column :tokens, :extra_info
  end

  def up_seed_scopes_for_api_particulier
    all_scopes.each do |scope|
      Scope.create!(
        name: scope['name'],
        code: scope['code'],
        api: :particulier
      )
    end
  end

  def down_seed_scopes_for_api_particulier
    Scope.where(api: 'particulier').delete_all
  end

  def all_scopes
    YAML.load_file(Rails.root.join('config/data/scopes/particulier.yml'))
  end
end
