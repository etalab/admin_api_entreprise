class IncidentIndexSerializer < ActiveModel::Serializer
  attributes :id, :title, :subtitle, :description, :created_at
end
