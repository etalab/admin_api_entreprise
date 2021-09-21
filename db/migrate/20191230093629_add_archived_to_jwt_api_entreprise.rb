class AddArchivedToJwtAPIEntreprise < ActiveRecord::Migration[6.0]
  def change
    add_column :jwt_api_entreprises, :archived, :boolean, default: false

    # Update tokens state: previsoully "blacklisted" tokens are in fact "archived"
    wrong_blacklist = JwtAPIEntreprise.where(blacklisted: true)
    wrong_blacklist.each do |t|
      t.update(blacklisted: false, archived: true) unless t.id == only_blacklisted_token
    end
  end

  def only_blacklisted_token
    # Occitanie token (sent by email)
    '625b84f2-9c99-40eb-a65b-7b5d593c5011'
  end
end
