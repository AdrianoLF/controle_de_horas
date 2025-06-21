require 'rails_helper'

RSpec.describe 'Members API', type: :request do
  let!(:user) { create(:user) }
  let!(:active_member) { create(:member, name: 'John Doe', active: true) }
  let!(:inactive_member) { create(:member, name: 'Jane Smith', active: false) }
  let(:auth_header) { auth_headers_for(user) }

  describe 'GET /api/v1/members' do
    it 'requires authentication' do
      get '/api/v1/members'
      expect(response).to have_http_status(:unauthorized)
    end

    context 'with authentication' do
      it 'filters by active status' do
        # Default: sem parâmetros, mostra todos
        get '/api/v1/members', headers: auth_header
        member_names = response.parsed_body['records'].map { |m| m['name'] }
        expect(member_names).to include('John Doe', 'Jane Smith')

        # Apenas ativos
        get '/api/v1/members?active=true', headers: auth_header
        member_names = response.parsed_body['records'].map { |m| m['name'] }
        expect(member_names).to include('John Doe')
        expect(member_names).not_to include('Jane Smith')

        # Apenas inativos
        get '/api/v1/members?active=false', headers: auth_header
        member_names = response.parsed_body['records'].map { |m| m['name'] }
        expect(member_names).to include('Jane Smith')
        expect(member_names).not_to include('John Doe')
      end

      it 'filters by teams' do
        team1 = create(:team, name: 'Frontend')
        team2 = create(:team, name: 'Backend')

        # Adiciona membros aos times
        team1.memberships.create!(member: active_member)
        team2.memberships.create!(member: inactive_member)

        # Filtra por time específico
        get "/api/v1/members?team_ids[]=#{team1.id}", headers: auth_header
        member_names = response.parsed_body['records'].map { |m| m['name'] }
        expect(member_names).to include('John Doe')
        expect(member_names).not_to include('Jane Smith')

        # Filtra por múltiplos times
        get "/api/v1/members?team_ids[]=#{team1.id}&team_ids[]=#{team2.id}", headers: auth_header
        member_names = response.parsed_body['records'].map { |m| m['name'] }
        expect(member_names).to include('John Doe', 'Jane Smith')
      end

      it 'combines filters (active + teams)' do
        team = create(:team, name: 'Development')
        team.memberships.create!(member: active_member)
        team.memberships.create!(member: inactive_member)

        # Apenas membros ativos do time Development
        get "/api/v1/members?active=true&team_ids[]=#{team.id}", headers: auth_header
        member_names = response.parsed_body['records'].map { |m| m['name'] }
        expect(member_names).to include('John Doe')
        expect(member_names).not_to include('Jane Smith')
      end

      it 'supports sorting' do
        create(:member, name: 'Alice', active: true)
        create(:member, name: 'Bob', active: true)

        # Ordenação crescente
        get '/api/v1/members?sort_by=name&sort_order=asc', headers: auth_header
        member_names = response.parsed_body['records'].map { |m| m['name'] }
        expect(member_names.first(3)).to eq(['Alice', 'Bob', 'Jane Smith'])

        # Ordenação decrescente
        get '/api/v1/members?sort_by=name&sort_order=desc', headers: auth_header
        member_names = response.parsed_body['records'].map { |m| m['name'] }
        expect(member_names.first(3)).to eq(['John Doe', 'Jane Smith', 'Bob'])
      end

      it 'searches by name' do
        get '/api/v1/members?name=John', headers: auth_header
        member_names = response.parsed_body['records'].map { |m| m['name'] }
        expect(member_names).to include('John Doe')
        expect(member_names).not_to include('Jane Smith')
      end
    end
  end

  describe 'PATCH /api/v1/members/:id' do
    it 'requires authentication' do
      patch "/api/v1/members/#{active_member.id}"
      expect(response).to have_http_status(:unauthorized)
    end

    it 'toggles member active status' do
      # Desativa membro ativo
      patch "/api/v1/members/#{active_member.id}",
            params: { active: false },
            headers: auth_header

      expect(response).to have_http_status(:success)
      expect(active_member.reload.active).to be false

      # Reativa membro inativo
      patch "/api/v1/members/#{active_member.id}",
            params: { active: true },
            headers: auth_header

      expect(response).to have_http_status(:success)
      expect(active_member.reload.active).to be true
    end

    it 'updates member data' do
      patch "/api/v1/members/#{active_member.id}",
            params: { name: 'John Updated', pix_key: '123456789' },
            headers: auth_header

      expect(response).to have_http_status(:success)
      active_member.reload
      expect(active_member.name).to eq('John Updated')
      expect(active_member.pix_key).to eq('123456789')
    end
  end
end
