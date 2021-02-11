class AddDouanesEoriRole < ActiveRecord::Migration[6.0]
  def up
    Role.create name: 'Douanes EORI', code: 'eori_douanes'
  end

  def down
    Role.delete_by code: 'eori_douanes'
  end
end
