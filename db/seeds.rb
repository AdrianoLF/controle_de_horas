user1 = User.create!(email: 'john@acme.inc', password: 'Password1!')

team_dev = Team.create!(
  name: 'Development Team',
  description: 'Main software development team'
)

team_design = Team.create!(
  name: 'Design Team',
  description: 'Product design and UX team'
)

5.times do
  Member.create!(
    name: Faker::Name.unique.name,
    email: Faker::Internet.unique.email
  )
end

Member.all.each do |member|
  [team_dev, team_design].each do |team|
    next if rand < 0.3
    Membership.create!(member: member, team: team)
  end
end

[team_dev, team_design].each do |team|
  10.times do
    event = Event.create!(
      team: team,
      title: ["Daily Meeting", "Code Review", "Sprint Planning", "Client Meeting", "Development"].sample,
      description: Faker::Company.bs,
      duration_seconds: [1800, 3600, 7200].sample
    )

    team.members.sample(rand(1..3)).each do |member|
      EventAssignment.create!(event: event, member: member)
    end
  end
end



