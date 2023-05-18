require 'csv'
require 'json'

namespace :datapass do
  desc 'Import datapass data from CSV'
  task :rebuild_user_authorization_request_roles, [:csv_path] => :environment do |_, args|
    filepath = args[:csv_path]

    raise 'File not found. Usage: rake datapass:rebuild_user_authorization_request_roles file.csv' unless File.exist?(filepath)

    datapass_data(filepath).each do |row|
      next unless row[:team_members].present? && row[:id].present?

      create_user_authorization_request_roles(row)
    end
  end

  private

  def datapass_data(filepath)
    datapass_data = []

    CSV.foreach(filepath, headers: true) do |row|
      datapass_data << row.to_hash
    end

    datapass_data.map! { |row|
      next unless row['team_members_json']

      {
        id: row['id'],
        team_members: JSON.parse(row['team_members_json'])
      }
    }.compact!

    datapass_data
  end

  def create_user_authorization_request_roles(row)
    authorization_request = AuthorizationRequest.find_by(external_id: row[:id])

    row[:team_members].each do |team_member|
      user = User.find_by(email: team_member['email'])

      role = team_member_to_contact[team_member['type']]

      unless user && authorization_request && role
        puts "Error: User #{team_member['email']} or AuthorizationRequest #{row[:id]} or role #{role} not found"
        next
      end

      puts "Will create new UserAuthorizationRequestRole for #{user.email} on AuthorizationRequest #{authorization_request.external_id} (role: #{role})"

      create_user_authorization_request_role(authorization_request, user, role)
    end
  end

  def create_user_authorization_request_role(authorization_request, user, role)
    UserAuthorizationRequestRole.create!(authorization_request:, user:, role:)
  rescue StandardError => e
    puts "Error: #{e.message} while creating Roles for #{user.email} on AuthorizationRequest #{authorization_request.external_id} (role: #{role})"
  end

  def team_member_to_contact
    {
      'contact_metier' => 'contact_metier',
      'responsable_technique' => 'contact_technique',
      'demandeur' => 'demandeur'
    }
  end
end
