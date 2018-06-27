class IncidentIndexSerializer < ActiveModel::Serializer
  attributes :id, :title, :subtitle, :description
end
