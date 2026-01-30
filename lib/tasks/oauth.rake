namespace :oauth do
  desc "Create OAuth app for an owner oauth:create_app\\['Editor','UUID'\\] or oauth:create_app\\['AuthorizationRequest','UUID'\\]"
  task :create_app, %i[owner_type owner_id] => :environment do |_, args|
    owner = args.owner_type.constantize.find(args.owner_id)
    oauth_app = owner.generate_oauth_credentials!

    puts 'OAuth Application created:'
    puts "  Client ID: #{oauth_app.uid}"
    puts "  Client Secret: #{oauth_app.secret}"
  end

  desc "Create delegation for editor oauth:create_delegation\\['EDITOR_UUID','AR_UUID'\\]"
  task :create_delegation, %i[editor_id authorization_request_id] => :environment do |_, args|
    editor = Editor.find(args.editor_id)
    authorization_request = AuthorizationRequest.find(args.authorization_request_id)

    delegation = EditorDelegation.create!(
      editor:,
      authorization_request:
    )

    puts "Delegation created: #{delegation.id}"
  end

  desc "Revoke a delegation oauth:revoke_delegation\\['DELEGATION_UUID'\\]"
  task :revoke_delegation, [:delegation_id] => :environment do |_, args|
    delegation = EditorDelegation.find(args.delegation_id)
    delegation.revoke!

    puts "Delegation #{delegation.id} revoked"
  end

  desc 'List all OAuth applications'
  task list_apps: :environment do
    OAuthApplication.includes(:owner).find_each do |app|
      puts "#{app.id} - #{app.name} (#{app.owner_type}: #{app.owner&.id})"
    end
  end

  desc "List all delegations for an editor oauth:list_delegations\\['EDITOR_UUID'\\]"
  task :list_delegations, [:editor_id] => :environment do |_, args|
    editor = Editor.find(args.editor_id)

    editor.editor_delegations.includes(:authorization_request).find_each do |delegation|
      status = delegation.active? ? 'active' : 'revoked'
      ar = delegation.authorization_request
      puts "#{delegation.id} - AR: #{ar.external_id} (#{status})"
    end
  end
end
