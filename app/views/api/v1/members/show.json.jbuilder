json.record do
  json.partial! 'api/v1/models/member', formats: [:json], resource: @member, cached: true
end

json.teams do
  json.array! @member.teams do |team|
    json.partial! 'api/v1/models/team', formats: [:json], resource: team
  end
end