require 'rails_helper'

RSpec.describe 'Events API', type: :request do
  let!(:user) { create(:user) }
  let!(:team) { create(:team) }

  let!(:old_event) { create(:event, team: team, occurred_at: 10.days.ago, title: 'Old Event') }
  let!(:middle_event) { create(:event, team: team, occurred_at: 5.days.ago, title: 'Middle Event') }
  let!(:new_event) { create(:event, team: team, occurred_at: 1.day.ago, title: 'New Event') }

  let(:auth_header) { auth_headers_for(user) }

  describe 'GET /api/v1/events' do
    it 'requires authentication' do
      get '/api/v1/events'
      expect(response).to have_http_status(:unauthorized)
    end

    context 'with authentication' do
      it 'returns all events by default ordered by occurred_at desc' do
        get '/api/v1/events', headers: auth_header
        titles = response.parsed_body['records'].map { |e| e['title'] }
        expect(titles).to eq(['New Event', 'Middle Event', 'Old Event'])
      end

      it 'filters by occurred_from (inclusive)' do
        get "/api/v1/events?occurred_from=#{5.days.ago.to_date}", headers: auth_header
        titles = response.parsed_body['records'].map { |e| e['title'] }
        expect(titles).to include('New Event', 'Middle Event')
        expect(titles).not_to include('Old Event')
      end

      it 'filters by occurred_to (inclusive)' do
        get "/api/v1/events?occurred_to=#{5.days.ago.to_date}", headers: auth_header
        titles = response.parsed_body['records'].map { |e| e['title'] }
        expect(titles).to include('Old Event', 'Middle Event')
        expect(titles).not_to include('New Event')
      end

      it 'filters by occurred_from and occurred_to' do
        params = {
          occurred_from: 6.days.ago.to_date,
          occurred_to: 2.days.ago.to_date
        }
        get '/api/v1/events', params: params, headers: auth_header
        titles = response.parsed_body['records'].map { |e| e['title'] }
        expect(titles).to eq(['Middle Event'])
      end

      it 'supports sorting by occurred_at asc' do
        get '/api/v1/events?sort_by=occurred_at&sort_order=asc', headers: auth_header
        titles = response.parsed_body['records'].map { |e| e['title'] }
        expect(titles).to eq(['Old Event', 'Middle Event', 'New Event'])
      end
    end
  end
end
