puts '🌱 Iniciando criação das seeds...'

User.create!(
  email: 'john@acme.inc',
  password: 'Password1!',
  super_admin: true,
  name: 'John Doe'
)
puts '✅ Usuário admin criado'

User.create!(
  email: 'leader@acme.inc',
  password: 'Password1!',
  super_admin: false,
  name: 'Leader Doe'
)
puts '✅ Usuário leader criado'

team_dev = Team.create!(
  name: 'Time de Desenvolvimento',
  description: 'Responsável pelo desenvolvimento de software, APIs e infraestrutura'
)

team_design = Team.create!(
  name: 'Time de Design',
  description: 'Responsável por UX/UI, prototipagem e design visual'
)

team_product = Team.create!(
  name: 'Time de Produto',
  description: 'Responsável por estratégia de produto, análise de mercado e roadmap'
)

team_qa = Team.create!(
  name: 'Time de QA',
  description: 'Responsável por testes, qualidade e validação de features'
)
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
  member = Member.create!(
    name: member_info[:name],
    email: member_info[:email],
    pix_key: member_info[:email]
  )

  member_info[:teams].each do |team|
    Membership.create!(
      member: member,
      team: team,
      role: member_info[:role]
    )
  end
end
puts '✅ Membros e memberships criados'

events_data = [
  {
    team: team_dev,
    title: 'Daily Standup',
    description: 'Reunião diária para alinhar o progresso das tarefas e identificar bloqueios',
    duration_seconds: 15.minutes.to_i,
    member_count: 4,
    occurred_at: 1.day.ago
  },
  {
    team: team_dev,
    title: 'Code Review - Feature Login',
    description: 'Revisão do código da nova funcionalidade de autenticação',
    duration_seconds: 1.hour.to_i,
    member_count: 3,
    occurred_at: 2.days.ago
  },
  {
    team: team_dev,
    title: 'Sprint Planning',
    description: 'Planejamento das tarefas para o próximo sprint de 2 semanas',
    duration_seconds: 2.hours.to_i,
    member_count: 4,
    occurred_at: 3.days.ago
  },
  {
    team: team_dev,
    title: 'Arquitetura - Microserviços',
    description: 'Discussão sobre migração para arquitetura de microserviços',
    duration_seconds: 3.hours.to_i,
    member_count: 3,
    occurred_at: 4.days.ago
  },
  {
    team: team_dev,
    title: 'Refatoração Database',
    description: 'Sessão de refatoração do schema do banco de dados',
    duration_seconds: 4.hours.to_i,
    member_count: 2,
    occurred_at: 5.days.ago
  },
  {
    team: team_design,
    title: 'Workshop de Design System',
    description: 'Criação e padronização do design system da empresa',
    duration_seconds: 4.hours.to_i,
    member_count: 2,
    occurred_at: 6.days.ago
  },
  {
    team: team_design,
    title: 'Prototipagem Mobile',
    description: 'Criação de protótipos para a versão mobile da aplicação',
    duration_seconds: 3.hours.to_i,
    member_count: 2,
    occurred_at: 7.days.ago
  },
  {
    team: team_design,
    title: 'User Research',
    description: 'Pesquisa com usuários para validar novas funcionalidades',
    duration_seconds: 2.hours.to_i,
    member_count: 1,
    occurred_at: 8.days.ago
  },
  {
    team: team_product,
    title: 'Product Discovery',
    description: 'Sessão de descoberta de novas oportunidades de produto',
    duration_seconds: 3.hours.to_i,
    member_count: 2,
    occurred_at: 9.days.ago
  },
  {
    team: team_product,
    title: 'Análise de Métricas',
    description: 'Análise das métricas de uso e performance do produto',
    duration_seconds: 1.hour.to_i,
    member_count: 2,
    occurred_at: 10.days.ago
  },
  {
    team: team_product,
    title: 'Roadmap Review',
    description: 'Revisão e priorização do roadmap trimestral',
    duration_seconds: 2.hours.to_i,
    member_count: 2,
    occurred_at: 11.days.ago
  },
  {
    team: team_qa,
    title: 'Testes de Regressão',
    description: 'Execução de testes de regressão após deploy',
    duration_seconds: 2.hours.to_i,
    member_count: 2,
    occurred_at: 12.days.ago
  },
  {
    team: team_qa,
    title: 'Automação de Testes',
    description: 'Desenvolvimento de testes automatizados E2E',
    duration_seconds: 4.hours.to_i,
    member_count: 1,
    occurred_at: 13.days.ago
  },
  {
    team: team_qa,
    title: 'Bug Bash Session',
    description: 'Sessão colaborativa de identificação de bugs',
    duration_seconds: 1.hour.to_i,
    member_count: 2,
    occurred_at: 14.days.ago
  }
]

events_data.each do |event_info|
  event = Event.create!(
    team: event_info[:team],
    title: event_info[:title],
    description: event_info[:description],
    duration_seconds: event_info[:duration_seconds],
    occurred_at: event_info[:occurred_at]
  )

  available_members = event_info[:team].members.to_a
  selected_members = available_members.sample(event_info[:member_count])

  selected_members.each do |member|
    EventAssignment.create!(event: event, member: member)
  end
end
puts '✅ Eventos e assignments criados'

cross_team_events = [
  {
    team: team_dev,
    title: 'Alinhamento Dev x Design',
    description: 'Reunião de alinhamento entre desenvolvimento e design sobre novas features',
    duration_seconds: 1.hour.to_i,
    custom_members: [team_dev.members.first, team_design.members.first],
    occurred_at: 15.days.ago
  },
  {
    team: team_product,
    title: 'All Hands Meeting',
    description: 'Reunião geral com todos os times para alinhamento estratégico',
    duration_seconds: 1.hour.to_i,
    custom_members: Member.joins(:memberships).where(memberships: { role: :leader }).distinct,
    occurred_at: 16.days.ago
  }
]

cross_team_events.each do |event_info|
  event = Event.create!(
    team: event_info[:team],
    title: event_info[:title],
    description: event_info[:description],
    duration_seconds: event_info[:duration_seconds],
    occurred_at: event_info[:occurred_at]
  )

  event_info[:custom_members].each do |member|
    next unless member.teams.exists?(event.team_id)

    EventAssignment.create!(event: event, member: member)
  end
end
puts '✅ Eventos cross-team criados'

puts "\n📊 RESUMO DOS DADOS CRIADOS:"
puts "👤 Usuários: #{User.count}"
puts "👥 Times: #{Team.count}"
puts "🧑‍💼 Membros: #{Member.count}"
puts "🔗 Memberships: #{Membership.count}"
puts "📅 Eventos: #{Event.count}"
puts "📝 Event Assignments: #{EventAssignment.count}"
puts "\n✨ Seeds executados com sucesso!"
