json.id resource.id
json.title resource.title
json.description resource.description
json.duration_seconds resource.duration_seconds
json.team_id resource.team_id
json.members_count resource.members.size
json.occurred_at resource.occurred_at
json.created_at resource.created_at
json.updated_at resource.updated_at

json.team do
  json.partial! 'api/v1/models/team', formats: [:json], resource: resource.team
end

json.members do
  json.array! resource.members do |member|
    json.partial! 'api/v1/models/member', formats: [:json], resource: member
  end
end
