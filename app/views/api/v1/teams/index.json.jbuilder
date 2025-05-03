json.records do
  json.array! @teams do |team|
    json.partial! 'api/v1/models/team', formats: [:json], resource: team, cached: true
  end
end

json.total_pages @teams.try(:total_pages) || 1
json.current_page @teams.try(:current_page) || 1
json.count_total @teams.try(:total_count) || @teams.count
