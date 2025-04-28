require 'rails_helper'

RSpec.describe 'Proponents API', type: :request do
  let!(:user) { create(:user) }
  let(:auth_header) { auth_headers_for(user) }
  let!(:proponent) { create(:proponent, user: user) }

  let(:query_params) do
    {
      cpf: nil,
      name: nil,
      discount_group: nil,
      page: 1
    }
  end
  let(:body_params) do
    {
      name: 'Beatriz Silva',
      birth_date: '1985-03-22T00:00:00.000Z',
      salary: 7500.50,
      cpf: '220.504.260-20',
      address_city: 'Rio de Janeiro',
      address_neighborhood: 'Copacabana',
      address_number: 1502,
      address_state: 'Rio de Janeiro',
      address_street: 'Rua Atlântica',
      address_zipcode: '22070030',
      phones: {
        reference: [
          { description: 'Brother', phone: '+55219987654321' },
          { description: 'Sister', phone: '+55219876543210' }
        ],
        personal: [
          { description: 'Mobile', phone: '+55219876543211' },
          { description: 'WhatsApp', phone: '+55219876543212' }
        ]
      }
    }
  end

  def hash_to_query(hash)
    URI.encode_www_form(hash.compact)
  end

  describe 'GET /api/v1/proponents' do
    let(:proponent_finder) { instance_double(ProponentFinder) }

    before do
      allow(ProponentFinder).to receive(:new).and_return(proponent_finder)
      allow(proponent_finder).to receive(:perform).and_return(Proponent.none)
    end

    context 'when it is an unauthenticated user' do
      it 'returns unauthorized' do
        get '/api/v1/proponents',
            as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when it is an authenticated user' do
      it 'returns success' do
        get "/api/v1/proponents?#{hash_to_query(query_params)}",
            headers: auth_header,
            as: :json

        expect(response).to have_http_status(:success)
      end

      it 'calls ProponentFinder' do
        get "/api/v1/proponents?#{hash_to_query(query_params)}",
            headers: auth_header,
            as: :json

        expect(proponent_finder).to have_received(:perform)
      end
    end
  end

  describe 'GET /api/v1/proponents/:id' do
    context 'when it is an unauthenticated user' do
      it 'returns unauthorized' do
        get "/api/v1/proponents/#{proponent.id}"

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when it is an authenticated user' do
      it 'returns success' do
        get "/api/v1/proponents/#{proponent.id}",
            headers: auth_header

        expect(response).to have_http_status(:success)
      end

      it 'returns the proponent' do
        get "/api/v1/proponents/#{proponent.id}",
            headers: auth_header

        expect(response.parsed_body['proponent']['id']).to eq(proponent.id)
      end
    end
  end

  describe 'POST /api/v1/proponents' do
    context 'when it is an unauthenticated user' do
      it 'returns unauthorized' do
        post '/api/v1/proponents'

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when it is an authenticated user' do
      it 'returns success' do
        post '/api/v1/proponents',
             params: body_params,
             headers: auth_header,
             as: :json

        expect(response).to have_http_status(:success)
      end

      it 'returns the proponent' do
        expect(Proponent.count).to eq(1)
        post '/api/v1/proponents',
             params: body_params,
             headers: auth_header,
             as: :json

        expect(Proponent.count).to eq(2)
        expect(response.parsed_body['proponent']['id']).to be_present
      end
    end
  end

  describe 'DELETE /api/v1/proponents/:id' do
    context 'when it is an unauthenticated user' do
      it 'returns unauthorized' do
        delete "/api/v1/proponents/#{proponent.id}"

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when it is an authenticated user' do
      it 'returns success' do
        delete "/api/v1/proponents/#{proponent.id}",
               headers: auth_header

        expect(response).to have_http_status(:success)
      end

      it 'returns the proponent' do
        expect(Proponent.count).to eq(1)
        delete "/api/v1/proponents/#{proponent.id}",
               headers: auth_header

        expect(Proponent.count).to eq(0)
      end
    end
  end

  describe 'PATCH /api/v1/proponents/:id' do
    context 'when it is an unauthenticated user' do
      it 'returns unauthorized' do
        patch "/api/v1/proponents/#{proponent.id}"

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when it is an authenticated user' do
      let(:initial_name) { proponent.name }
      let(:update_params) { { name: "#{initial_name} edited" } }

      it 'returns success' do
        patch "/api/v1/proponents/#{proponent.id}",
              params: update_params,
              headers: auth_header,
              as: :json

        expect(response).to have_http_status(:success)
      end

      it 'returns the proponent' do
        patch "/api/v1/proponents/#{proponent.id}",
              params: update_params,
              headers: auth_header,
              as: :json

        expect(proponent.name).to eq(initial_name)
        proponent.reload
        expect(proponent.name).to eq("#{initial_name} edited")
      end
    end
  end

  describe 'GET /api/v1/proponents/report' do
    let(:report_builder) { instance_double(ReportBuilder) }

    before do
      allow(ReportBuilder).to receive(:new).and_return(report_builder)
      allow(report_builder).to receive(:report_by_discount_group)
    end

    context 'when it is an unauthenticated user' do
      it 'returns unauthorized' do
        get '/api/v1/proponents/report'

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when it is an authenticated user' do
      it 'returns success' do
        get '/api/v1/proponents/report',
            headers: auth_header

        expect(response).to have_http_status(:success)
      end

      it 'calls ProponentFinder' do
        get '/api/v1/proponents/report',
            headers: auth_header

        expect(report_builder).to have_received(:report_by_discount_group)
      end
    end
  end
end
