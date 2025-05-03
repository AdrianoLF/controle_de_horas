json.record do
  json.partial! 'api/v1/models/team', formats: [:json], resource: @team, cached: true
end

json.members do
  json.array! @team.members do |member|
    json.partial! 'api/v1/models/member', formats: [:json], resource: member
  end
end