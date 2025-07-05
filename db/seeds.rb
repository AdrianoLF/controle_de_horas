puts '🌱 Iniciando criação das seeds...'

User.find_or_create_by!(email: 'john@acme.inc') do |user|
  user.password = 'Password1!'
  user.super_admin = true
  user.name = 'John Doe'
end
puts '✅ Usuário admin criado'

User.find_or_create_by!(email: 'leader@acme.inc') do |user|
  user.password = 'Password1!'
  user.super_admin = false
  user.name = 'Leader Doe'
end
puts '✅ Usuário leader criado'

team_dev = Team.find_or_create_by!(name: 'Time de Desenvolvimento') do |team|
  team.description = 'Responsável pelo desenvolvimento de software, APIs e infraestrutura'
end

team_design = Team.find_or_create_by!(name: 'Time de Design') do |team|
  team.description = 'Responsável por UX/UI, prototipagem e design visual'
end

team_product = Team.find_or_create_by!(name: 'Time de Produto') do |team|
  team.description = 'Responsável por estratégia de produto, análise de mercado e roadmap'
end

team_qa = Team.find_or_create_by!(name: 'Time de QA') do |team|
  team.description = 'Responsável por testes, qualidade e validação de features'
end
puts '✅ Times criados'

members_data = [
  { name: 'Ana Silva', email: 'ana.silva@empresa.com', role: :leader, teams: [team_dev] },
  { name: 'Bruno Santos', email: 'bruno.santos@empresa.com', role: :member, teams: [team_dev] },
  { name: 'Carlos Oliveira', email: 'carlos.oliveira@empresa.com', role: :member, teams: [team_dev] },
  { name: 'Daniela Costa', email: 'daniela.costa@empresa.com', role: :leader, teams: [team_design] },
  { name: 'Eduardo Lima', email: 'eduardo.lima@empresa.com', role: :member, teams: [team_design] },
  { name: 'Fernanda Alves', email: 'fernanda.alves@empresa.com', role: :leader, teams: [team_product] },
  { name: 'Gabriel Rocha', email: 'gabriel.rocha@empresa.com', role: :member, teams: [team_product] },
  { name: 'Helena Martins', email: 'helena.martins@empresa.com', role: :leader, teams: [team_qa] },
  { name: 'Igor Ferreira', email: 'igor.ferreira@empresa.com', role: :member, teams: [team_qa] },
  { name: 'Julia Pereira', email: 'julia.pereira@empresa.com', role: :member, teams: [team_dev, team_qa] }
]

members_data.each do |member_info|
  member = Member.find_or_create_by!(email: member_info[:email]) do |m|
    m.name = member_info[:name]
    m.pix_key = member_info[:email]
  end

  member_info[:teams].each do |team|
    Membership.find_or_create_by!(member: member, team: team) do |membership|
      membership.role = member_info[:role]
    end
  end
end
puts '✅ Membros e memberships criados'

events_data = [
  {
    teams: [team_dev],
    title: 'Daily Standup',
    description: 'Reunião diária para alinhar o progresso das tarefas e identificar bloqueios',
    duration_seconds: 15.minutes.to_i,
    member_count: 4,
    occurred_at: 1.day.ago
  },
  {
    teams: [team_dev],
    title: 'Code Review - Feature Login',
    description: 'Revisão do código da nova funcionalidade de autenticação',
    duration_seconds: 1.hour.to_i,
    member_count: 3,
    occurred_at: 2.days.ago
  },
  {
    teams: [team_dev],
    title: 'Sprint Planning',
    description: 'Planejamento das tarefas para o próximo sprint de 2 semanas',
    duration_seconds: 2.hours.to_i,
    member_count: 4,
    occurred_at: 3.days.ago
  },
  {
    teams: [team_dev],
    title: 'Arquitetura - Microserviços',
    description: 'Discussão sobre migração para arquitetura de microserviços',
    duration_seconds: 3.hours.to_i,
    member_count: 3,
    occurred_at: 4.days.ago
  },
  {
    teams: [team_dev],
    title: 'Refatoração Database',
    description: 'Sessão de refatoração do schema do banco de dados',
    duration_seconds: 4.hours.to_i,
    member_count: 2,
    occurred_at: 5.days.ago
  },
  {
    teams: [team_design],
    title: 'Workshop de Design System',
    description: 'Criação e padronização do design system da empresa',
    duration_seconds: 4.hours.to_i,
    member_count: 2,
    occurred_at: 6.days.ago
  },
  {
    teams: [team_design],
    title: 'Prototipagem Mobile',
    description: 'Criação de protótipos para a versão mobile da aplicação',
    duration_seconds: 3.hours.to_i,
    member_count: 2,
    occurred_at: 7.days.ago
  },
  {
    teams: [team_design],
    title: 'User Research',
    description: 'Pesquisa com usuários para validar novas funcionalidades',
    duration_seconds: 2.hours.to_i,
    member_count: 1,
    occurred_at: 8.days.ago
  },
  {
    teams: [team_product],
    title: 'Product Discovery',
    description: 'Sessão de descoberta de novas oportunidades de produto',
    duration_seconds: 3.hours.to_i,
    member_count: 2,
    occurred_at: 9.days.ago
  },
  {
    teams: [team_product],
    title: 'Análise de Métricas',
    description: 'Análise das métricas de uso e performance do produto',
    duration_seconds: 1.hour.to_i,
    member_count: 2,
    occurred_at: 10.days.ago
  },
  {
    teams: [team_product],
    title: 'Roadmap Review',
    description: 'Revisão e priorização do roadmap trimestral',
    duration_seconds: 2.hours.to_i,
    member_count: 2,
    occurred_at: 11.days.ago
  },
  {
    teams: [team_qa],
    title: 'Testes de Regressão',
    description: 'Execução de testes de regressão após deploy',
    duration_seconds: 2.hours.to_i,
    member_count: 2,
    occurred_at: 12.days.ago
  },
  {
    teams: [team_qa],
    title: 'Automação de Testes',
    description: 'Desenvolvimento de testes automatizados E2E',
    duration_seconds: 4.hours.to_i,
    member_count: 1,
    occurred_at: 13.days.ago
  },
  {
    teams: [team_qa],
    title: 'Bug Bash Session',
    description: 'Sessão colaborativa de identificação de bugs',
    duration_seconds: 1.hour.to_i,
    member_count: 2,
    occurred_at: 14.days.ago
  }
]

events_data.each do |event_info|
  event = Event.find_by(title: event_info[:title])

  next if event

  event = Event.new(
    title: event_info[:title],
    description: event_info[:description],
    duration_seconds: event_info[:duration_seconds],
    occurred_at: event_info[:occurred_at]
  )

  event_info[:teams].each do |team|
    event.teams << team
  end

  event.save!

  available_members = Member.joins(:teams).where(teams: { id: event_info[:teams].map(&:id) }).distinct.to_a
  selected_members = available_members.sample(event_info[:member_count])

  selected_members.each do |member|
    EventAssignment.create!(event: event, member: member)
  end
end
puts '✅ Eventos e assignments criados'

cross_team_events = [
  {
    teams: [team_dev, team_design],
    title: 'Alinhamento Dev x Design',
    description: 'Reunião de alinhamento entre desenvolvimento e design sobre novas features',
    duration_seconds: 1.hour.to_i,
    custom_members: [team_dev.members.first, team_design.members.first],
    occurred_at: 15.days.ago
  },
  {
    teams: [team_dev, team_design, team_product, team_qa],
    title: 'All Hands Meeting',
    description: 'Reunião geral com todos os times para alinhamento estratégico',
    duration_seconds: 1.hour.to_i,
    custom_members: Member.joins(:memberships).where(memberships: { role: :leader }).distinct,
    occurred_at: 16.days.ago
  },
  {
    teams: [team_dev, team_qa],
    title: 'Revisão de Qualidade',
    description: 'Alinhamento sobre processos de qualidade e testes automatizados',
    duration_seconds: 2.hours.to_i,
    custom_members: [team_dev.members.sample(2), team_qa.members.sample(2)].flatten,
    occurred_at: 17.days.ago
  },
  {
    teams: [team_design, team_product],
    title: 'Discovery Session',
    description: 'Sessão de descoberta para definir novas features baseadas em pesquisa',
    duration_seconds: 3.hours.to_i,
    custom_members: [team_design.members.first, team_product.members.first],
    occurred_at: 18.days.ago
  }
]

cross_team_events.each do |event_info|
  event = Event.find_by(title: event_info[:title])

  next if event

  event = Event.new(
    title: event_info[:title],
    description: event_info[:description],
    duration_seconds: event_info[:duration_seconds],
    occurred_at: event_info[:occurred_at]
  )

  event_info[:teams].each do |team|
    event.teams << team
  end

  event.save!

  event_team_ids = event_info[:teams].map(&:id)

  event_info[:custom_members].each do |member|
    next unless member.teams.where(id: event_team_ids).exists?

    EventAssignment.find_or_create_by!(event: event, member: member)
  end
end
puts '✅ Eventos cross-team criados'

puts "\n📊 RESUMO DOS DADOS CRIADOS:"
puts "👤 Usuários: #{User.count}"
puts "👥 Times: #{Team.count}"
puts "🧑‍💼 Membros: #{Member.count}"
puts "🔗 Memberships: #{Membership.count}"
puts "📅 Eventos: #{Event.count}"
puts "🔗 Event Teams: #{EventTeam.count}"
puts "📝 Event Assignments: #{EventAssignment.count}"
multi_team_events = Event.joins(:event_teams).group('events.id').having('COUNT(event_teams.team_id) > 1').count.size
puts "🤝 Eventos Multi-Team: #{multi_team_events}"
puts "\n✨ Seeds executados com sucesso!"
