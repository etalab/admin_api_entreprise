class DowncaseUserEmails < ActiveRecord::Migration[8.1]
  def up
    safety_assured do
      execute <<-SQL.squish
        UPDATE users SET email = LOWER(TRIM(email)) WHERE email IS NOT NULL
      SQL
    end
  end

  def down
  end
end
