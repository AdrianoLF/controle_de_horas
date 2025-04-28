require 'rails_helper'

RSpec.describe 'INSS Calculation API', type: :request do
  let!(:user) { create(:user) }
  let(:auth_header) { auth_headers_for(user) }
  let(:params) { { salary: 3000 } }

  describe 'POST /api/v1/inss_calculations/discount' do
    context 'when it is an unauthenticated user' do
      it 'returns unauthorized' do
        post '/api/v1/inss_calculations/discount',
             params: params,
             as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when it is an authenticated user' do
      it 'returns success' do
        post '/api/v1/inss_calculations/discount',
             params: params,
             headers: auth_header,
             as: :json

        expect(response).to have_http_status(:success)
      end

      it 'calls InssDiscountCalculatorService' do
        discount_calculator_service = instance_double(InssDiscountCalculatorService)
        allow(InssDiscountCalculatorService).to receive(:new).and_return(discount_calculator_service)
        allow(discount_calculator_service).to receive(:perform)

        post '/api/v1/inss_calculations/discount',
             params: params,
             headers: auth_header,
             as: :json

        expect(discount_calculator_service).to have_received(:perform)
      end
    end
  end
end
