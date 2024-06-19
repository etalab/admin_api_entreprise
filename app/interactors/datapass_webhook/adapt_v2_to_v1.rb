class DatapassWebhook::AdaptV2ToV1 < ApplicationInteractor
  def call
    context.event = context.event.sub('authorization_request', 'enrollment')
    context.authorization_request_data = generic_data.dup
    context.data = build_data
  end

  private

  # rubocop:disable Metrics/AbcSize
  def build_data
    {
      'pass' => {
        'id' => context.model_id,
        'public_id' => context.data['public_id'],
        'intitule' => generic_data['intitule'],
        'description' => generic_data['description'],
        'demarche' => context.data['form_uid'],
        'siret' => context.data['organization']['siret'],
        'status' => context.data['state'],
        'copied_from_enrollment_id' => nil,
        'previous_enrollment_id' => nil,
        'scopes' => generic_data['scopes'].index_with { |_scope| true },
        'team_members' => build_team_members,
        'events' => []
      }
    }
  end
  # rubocop:enable Metrics/AbcSize

  def build_team_members
    build_contacts + [applicant_as_team_member]
  end

  def build_contacts
    {
      'contact_metier' => 'contact_metier',
      'contact_technique' => 'responsable_technique'
    }.each_with_object([]) do |(v2_type, v1_type), acc|
      acc << {
        'id' => nil,
        'uid' => nil,
        'type' => v1_type,
        'given_name' => generic_data["#{v2_type}_given_name"],
        'family_name' => generic_data["#{v2_type}_family_name"],
        'email' => generic_data["#{v2_type}_email"],
        'phone_number' => generic_data["#{v2_type}_phone_number"],
        'job' => generic_data["#{v2_type}_job_title"]
      }
    end
  end

  def applicant_as_team_member
    {
      'id' => applicant_data['id'],
      'uid' => nil,
      'type' => 'demandeur',
      'given_name' => applicant_data['given_name'],
      'family_name' => applicant_data['family_name'],
      'email' => applicant_data['email'],
      'phone_number' => applicant_data['phone_number'],
      'job' => applicant_data['job_title']
    }
  end

  def applicant_data
    context.data['applicant']
  end

  def generic_data
    context.data['data']
  end
end
