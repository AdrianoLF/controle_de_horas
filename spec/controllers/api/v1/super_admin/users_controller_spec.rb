require 'rails_helper'

RSpec.describe 'Super Admin Users API', type: :request do
  let!(:super_admin_user) { create(:user, super_admin: true, name: 'Super Admin', email: 'super@admin.com') }
  let!(:regular_user) { create(:user, super_admin: false, name: 'Regular User', email: 'regular@user.com') }
  let!(:active_user) { create(:user, name: 'Active User', email: 'active@user.com', suspended: false) }
  let!(:suspended_user) { create(:user, name: 'Suspended User', email: 'suspended@user.com', suspended: true) }

  let(:super_admin_auth_header) { auth_headers_for(super_admin_user) }
  let(:regular_auth_header) { auth_headers_for(regular_user) }

  describe 'GET /api/v1/super_admin/users' do
    context 'authentication and authorization' do
      it 'requires authentication' do
        get '/api/v1/super_admin/users'
        expect(response).to have_http_status(:unauthorized)
      end

      it 'requires super admin privileges' do
        get '/api/v1/super_admin/users', headers: regular_auth_header
        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body['error']).to include('super admin')
      end
    end

    context 'with super admin authentication' do
      it 'returns all users ordered by name' do
        get '/api/v1/super_admin/users', headers: super_admin_auth_header

        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json['records']).to be_present

        user_names = json['records'].map { |u| u['name'] }
        expect(user_names).to include('Active User', 'Suspended User', 'Regular User', 'Super Admin')
        expect(user_names).to eq(user_names.sort)
      end

      it 'includes expected user attributes' do
        get '/api/v1/super_admin/users', headers: super_admin_auth_header

        expect(response).to have_http_status(:ok)
        user_record = response.parsed_body['records'].first

        expect(user_record).to have_key('id')
        expect(user_record).to have_key('name')
        expect(user_record).to have_key('email')
        expect(user_record).to have_key('suspended')
        expect(user_record).to have_key('super_admin')
        expect(user_record).to have_key('created_at')
        expect(user_record).to have_key('updated_at')
      end

      it 'includes pagination metadata' do
        get '/api/v1/super_admin/users', headers: super_admin_auth_header

        expect(response).to have_http_status(:ok)
        json = response.parsed_body

        expect(json).to have_key('total_pages')
        expect(json).to have_key('current_page')
        expect(json).to have_key('total_count')
      end

      context 'search functionality' do
        it 'searches by name' do
          get '/api/v1/super_admin/users?name=Active', headers: super_admin_auth_header

          expect(response).to have_http_status(:ok)
          user_names = response.parsed_body['records'].map { |u| u['name'] }
          expect(user_names).to include('Active User')
          expect(user_names).not_to include('Suspended User', 'Regular User', 'Super Admin')
        end

        it 'searches by email' do
          get '/api/v1/super_admin/users?name=active@user.com', headers: super_admin_auth_header

          expect(response).to have_http_status(:ok)
          user_emails = response.parsed_body['records'].map { |u| u['email'] }
          expect(user_emails).to include('active@user.com')
          expect(user_emails).not_to include('suspended@user.com', 'regular@user.com', 'super@admin.com')
        end

        it 'performs case insensitive search' do
          get '/api/v1/super_admin/users?name=ACTIVE', headers: super_admin_auth_header

          expect(response).to have_http_status(:ok)
          user_names = response.parsed_body['records'].map { |u| u['name'] }
          expect(user_names).to include('Active User')
        end

        it 'returns empty results when no match found' do
          get '/api/v1/super_admin/users?name=nonexistent', headers: super_admin_auth_header

          expect(response).to have_http_status(:ok)
          expect(response.parsed_body['records']).to be_empty
        end
      end

      context 'status filtering' do
        it 'filters by active status' do
          get '/api/v1/super_admin/users?status=active', headers: super_admin_auth_header

          expect(response).to have_http_status(:ok)
          user_emails = response.parsed_body['records'].map { |u| u['email'] }
          expect(user_emails).to include('active@user.com', 'regular@user.com', 'super@admin.com')
          expect(user_emails).not_to include('suspended@user.com')
        end

        it 'filters by suspended status' do
          get '/api/v1/super_admin/users?status=suspended', headers: super_admin_auth_header

          expect(response).to have_http_status(:ok)
          user_emails = response.parsed_body['records'].map { |u| u['email'] }
          expect(user_emails).to include('suspended@user.com')
          expect(user_emails).not_to include('active@user.com', 'regular@user.com', 'super@admin.com')
        end

        it 'returns all users when status filter is invalid' do
          get '/api/v1/super_admin/users?status=invalid', headers: super_admin_auth_header

          expect(response).to have_http_status(:ok)
          user_count = response.parsed_body['records'].count
          expect(user_count).to eq(4)
        end
      end

      context 'combined filters' do
        it 'combines search and status filters' do
          get '/api/v1/super_admin/users?name=user&status=suspended', headers: super_admin_auth_header

          expect(response).to have_http_status(:ok)
          records = response.parsed_body['records']
          expect(records.length).to eq(1)
          expect(records.first['email']).to eq('suspended@user.com')
        end
      end
    end

    context 'pagination' do
      before do
        10.times do |i|
          create(:user, name: "Pagination Test #{i}", email: "pagtest#{i}@example.com")
        end
      end

      after do
        User.where('email LIKE ?', 'pagtest%').destroy_all
      end

      it 'paginates results' do
        get '/api/v1/super_admin/users?page=1', headers: super_admin_auth_header

        expect(response).to have_http_status(:ok)
        json = response.parsed_body

        expect(json['current_page']).to eq(1)
        expect(json['total_count']).to eq(14)
        expect(json['records'].count).to be <= 10
      end

      it 'respects page parameter' do
        get '/api/v1/super_admin/users?page=2', headers: super_admin_auth_header

        expect(response).to have_http_status(:ok)
        json = response.parsed_body

        expect(json['current_page']).to eq(2)
      end
    end
  end

  describe 'PATCH /api/v1/super_admin/users/:id' do
    context 'authentication and authorization' do
      it 'requires authentication' do
        patch "/api/v1/super_admin/users/#{active_user.id}", params: { name: 'Updated' }
        expect(response).to have_http_status(:unauthorized)
      end

      it 'requires super admin privileges' do
        patch "/api/v1/super_admin/users/#{active_user.id}",
              params: { name: 'Updated' },
              headers: regular_auth_header
        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body['error']).to include('super admin')
      end
    end

    context 'with super admin authentication' do
      context 'successful updates' do
        it 'updates user basic information' do
          patch "/api/v1/super_admin/users/#{active_user.id}",
                params: { name: 'Updated Name', email: 'updated@email.com' },
                headers: super_admin_auth_header

          expect(response).to be_successful

          json = response.parsed_body
          expect(json['record']['name']).to eq('Updated Name')
          expect(json['record']['email']).to eq('updated@email.com')

          active_user.reload
          expect(active_user.name).to eq('Updated Name')
          expect(active_user.email).to eq('updated@email.com')
        end

        it 'suspends user' do
          patch "/api/v1/super_admin/users/#{active_user.id}",
                params: { suspended: true },
                headers: super_admin_auth_header

          expect(response).to be_successful

          json = response.parsed_body
          expect(json['record']['suspended']).to be true

          active_user.reload
          expect(active_user.suspended).to be true
        end

        it 'unsuspends user' do
          patch "/api/v1/super_admin/users/#{suspended_user.id}",
                params: { suspended: false },
                headers: super_admin_auth_header

          expect(response).to be_successful

          json = response.parsed_body
          expect(json['record']['suspended']).to be false

          suspended_user.reload
          expect(suspended_user.suspended).to be false
        end

        it 'promotes user to super admin' do
          patch "/api/v1/super_admin/users/#{regular_user.id}",
                params: { super_admin: true },
                headers: super_admin_auth_header

          expect(response).to be_successful

          json = response.parsed_body
          expect(json['record']['super_admin']).to be true

          regular_user.reload
          expect(regular_user.super_admin).to be true
        end

        it 'demotes super admin to regular user' do
          another_super_admin = create(:user, super_admin: true, name: 'Another Super Admin')

          patch "/api/v1/super_admin/users/#{another_super_admin.id}",
                params: { super_admin: false },
                headers: super_admin_auth_header

          expect(response).to be_successful

          json = response.parsed_body
          expect(json['record']['super_admin']).to be false

          another_super_admin.reload
          expect(another_super_admin.super_admin).to be false
        end

        it 'handles password update when confirmation is provided' do
          patch "/api/v1/super_admin/users/#{active_user.id}",
                params: { password: 'NewPassword123!', password_confirmation: 'NewPassword123!' },
                headers: super_admin_auth_header

          expect(response).to be_successful

          active_user.reload
          expect(active_user.valid_password?('NewPassword123!')).to be true
        end

        it 'allows updating multiple attributes at once' do
          patch "/api/v1/super_admin/users/#{active_user.id}",
                params: {
                  name: 'Multi Updated User',
                  email: 'multi@updated.com',
                  suspended: true,
                  super_admin: true
                },
                headers: super_admin_auth_header

          expect(response).to be_successful

          active_user.reload
          expect(active_user.name).to eq('Multi Updated User')
          expect(active_user.email).to eq('multi@updated.com')
          expect(active_user.suspended).to be true
          expect(active_user.super_admin).to be true
        end
      end

      context 'validation errors' do
        it 'validates email uniqueness' do
          patch "/api/v1/super_admin/users/#{active_user.id}",
                params: { email: regular_user.email },
                headers: super_admin_auth_header

          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body['errors']).to include('Email has already been taken')
        end

        it 'validates password when both password and confirmation are present but differ' do
          patch "/api/v1/super_admin/users/#{active_user.id}",
                params: { password: 'NewPassword123!', password_confirmation: 'DifferentPassword' },
                headers: super_admin_auth_header

          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body['errors']).to include("Password confirmation doesn't match Password")
        end
      end

      context 'error handling' do
        it 'returns 404 for non-existent user' do
          patch '/api/v1/super_admin/users/99999',
                params: { name: 'Updated' },
                headers: super_admin_auth_header

          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end

  describe 'POST /api/v1/super_admin/users' do
    context 'authentication and authorization' do
      it 'requires authentication' do
        post '/api/v1/super_admin/users', params: { name: 'New User', email: 'new@user.com' }
        expect(response).to have_http_status(:unauthorized)
      end

      it 'requires super admin privileges' do
        post '/api/v1/super_admin/users',
             params: { name: 'New User', email: 'new@user.com' },
             headers: regular_auth_header
        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body['error']).to include('super admin')
      end
    end

    context 'with super admin authentication' do
      context 'successful creation' do
        it 'creates a new user with basic information' do
          expect do
            post '/api/v1/super_admin/users',
                 params: {
                   name: 'New User',
                   email: 'new@user.com',
                   password: 'Password123!',
                   password_confirmation: 'Password123!'
                 },
                 headers: super_admin_auth_header
          end.to change(User, :count).by(1)

          expect(response).to be_successful

          json = response.parsed_body
          expect(json['record']['name']).to eq('New User')
          expect(json['record']['email']).to eq('new@user.com')
          expect(json['record']['super_admin']).to be false
          expect(json['record']['suspended']).to be false

          new_user = User.find(json['record']['id'])
          expect(new_user.valid_password?('Password123!')).to be true
        end

        it 'creates a super admin user' do
          expect do
            post '/api/v1/super_admin/users',
                 params: {
                   name: 'New Super Admin',
                   email: 'newsuper@admin.com',
                   super_admin: true,
                   password: 'Password123!',
                   password_confirmation: 'Password123!'
                 },
                 headers: super_admin_auth_header
          end.to change(User, :count).by(1)

          expect(response).to be_successful

          json = response.parsed_body
          expect(json['record']['super_admin']).to be true

          new_user = User.find(json['record']['id'])
          expect(new_user.super_admin).to be true
        end

        it 'creates a suspended user' do
          expect do
            post '/api/v1/super_admin/users',
                 params: {
                   name: 'Suspended User',
                   email: 'suspended@new.com',
                   password: 'Password123!',
                   password_confirmation: 'Password123!',
                   suspended: true
                 },
                 headers: super_admin_auth_header
          end.to change(User, :count).by(1)

          expect(response).to be_successful

          json = response.parsed_body
          expect(json['record']['suspended']).to be true

          new_user = User.find(json['record']['id'])
          expect(new_user.suspended).to be true
        end

        it 'creates user with all attributes' do
          expect do
            post '/api/v1/super_admin/users',
                 params: {
                   name: 'Complete User',
                   email: 'complete@user.com',
                   password: 'Password123!',
                   password_confirmation: 'Password123!',
                   super_admin: true,
                   suspended: false
                 },
                 headers: super_admin_auth_header
          end.to change(User, :count).by(1)

          expect(response).to be_successful

          new_user = User.find(response.parsed_body['record']['id'])
          expect(new_user.name).to eq('Complete User')
          expect(new_user.email).to eq('complete@user.com')
          expect(new_user.super_admin).to be true
          expect(new_user.suspended).to be false
          expect(new_user.valid_password?('Password123!')).to be true
        end
      end

      context 'validation errors' do
        it 'validates email presence' do
          post '/api/v1/super_admin/users',
               params: {
                 name: 'User Without Email',
                 password: 'Password123!',
                 password_confirmation: 'Password123!'
               },
               headers: super_admin_auth_header

          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body['errors']).to include("Email can't be blank")
        end

        it 'validates email uniqueness' do
          post '/api/v1/super_admin/users',
               params: {
                 name: 'Duplicate Email User',
                 email: active_user.email,
                 password: 'Password123!',
                 password_confirmation: 'Password123!'
               },
               headers: super_admin_auth_header

          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body['errors']).to include('Email has already been taken')
        end

        it 'validates password confirmation' do
          post '/api/v1/super_admin/users',
               params: {
                 name: 'Password Mismatch User',
                 email: 'mismatch@user.com',
                 password: 'Password123!',
                 password_confirmation: 'DifferentPassword'
               },
               headers: super_admin_auth_header

          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body['errors']).to include("Password confirmation doesn't match Password")
        end

        it 'validates password presence' do
          post '/api/v1/super_admin/users',
               params: {
                 name: 'No Password User',
                 email: 'nopassword@user.com'
               },
               headers: super_admin_auth_header

          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body['errors']).to include("Password can't be blank")
        end
      end
    end
  end
end
