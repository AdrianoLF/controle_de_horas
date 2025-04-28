require 'rails_helper'

RSpec.describe 'INSS Calculation API', type: :request do
  let!(:user) { create(:user) }
  let(:auth_header) { auth_headers_for(user) }

  describe 'get /api/v1/members' do
    context 'when it is an unauthenticated user' do
      it 'returns unauthorized' do
        get '/api/v1/members'

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when it is an authenticated user' do
      it 'returns success' do
        get '/api/v1/members',
            headers: auth_header

        expect(response).to have_http_status(:success)
      end

      it 'returns current user' do
        get '/api/v1/members',
            headers: auth_header

        expect(response.parsed_body['user']['id']).to eq(user.id)
      end
    end
  end
end
