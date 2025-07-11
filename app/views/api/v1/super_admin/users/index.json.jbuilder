json.records do
  json.array! @users do |user|
    json.partial! 'api/v1/models/user', formats: [:json], resource: user
  end
end

json.total_pages @users.try(:total_pages) || 1
json.current_page @users.try(:current_page) || 1
json.total_count @users.try(:total_count) || @users.count
