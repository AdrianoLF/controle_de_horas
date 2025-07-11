require 'rails_helper'

RSpec.describe Api::V1::PublicReportsController, type: :request do
  let!(:team) { create(:team) }
  let!(:member1) { create(:member, name: 'João Silva', external_id: '12345678901') }
  let!(:member2) { create(:member, name: 'Maria Santos', external_id: '98765432100') }

  let!(:event1) do
    event = build(:event, duration_seconds: 3600)
    event.teams << team
    event.save!
    event
  end

  let!(:event2) do
    event = build(:event, duration_seconds: 1800)
    event.teams << team
    event.save!
    event
  end

  before do
    create(:membership, member: member1, team: team)
    create(:membership, member: member2, team: team)
    create(:event_assignment, member: member1, event: event1)
    create(:event_assignment, member: member1, event: event2)
    create(:event_assignment, member: member2, event: event1)
  end

  describe 'GET /api/v1/public_reports/hours' do
    it 'does not require authentication' do
      get "/api/v1/public_reports/hours?ra=#{member1.external_id}"
      expect(response).to have_http_status(:ok)
    end

    it 'returns member hours data for valid external_id' do
      get "/api/v1/public_reports/hours?ra=#{member1.external_id}"

      expect(response).to have_http_status(:ok)
      data = response.parsed_body

      expect(data['record']['id']).to eq(member1.id)
      expect(data['record']['name']).to eq('João Silva')
      expect(data['record']['total_seconds']).to eq(5400)
      expect(data['record']['event_count']).to eq(2)

      expect(data['record']['events']).to be_an(Array)
      expect(data['record']['events'].size).to eq(2)
    end

    it 'returns correct data for different member' do
      get "/api/v1/public_reports/hours?ra=#{member2.external_id}"

      expect(response).to have_http_status(:ok)
      data = response.parsed_body

      expect(data['record']['id']).to eq(member2.id)
      expect(data['record']['name']).to eq('Maria Santos')
      expect(data['record']['total_seconds']).to eq(3600)
      expect(data['record']['event_count']).to eq(1)
    end

    it 'returns 404 for non-existent external_id' do
      get '/api/v1/public_reports/hours?ra=00000000000'

      expect(response).to have_http_status(:not_found)
    end

    it 'returns 404 when ra parameter is missing' do
      get '/api/v1/public_reports/hours'

      expect(response).to have_http_status(:not_found)
    end
  end
end
