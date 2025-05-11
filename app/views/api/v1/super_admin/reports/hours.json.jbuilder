json.records do
  json.array! @members_with_hours do |report_each_member|
    json.id report_each_member.member_id
    json.name report_each_member.member_name
    json.created_at report_each_member.member_created_at
    json.total_seconds report_each_member.total_seconds&.to_i || 0
    json.event_count report_each_member.event_count&.to_i || 0
  end
end

json.total_pages @members_with_hours.try(:total_pages) || 1
json.current_page @members_with_hours.try(:current_page) || 1
json.total_count @members_with_hours.try(:total_count) || @members_with_hours.count