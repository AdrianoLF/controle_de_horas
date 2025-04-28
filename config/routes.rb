require 'sidekiq/web'
Rails.application.routes.draw do
  devise_for :users,
             controllers: {
               sessions: 'users/sessions',
               registrations: 'users/registrations'
             }
  authenticate :user do
    mount Sidekiq::Web => '/sidekiq'
  end

  root 'pages#home'
  namespace :api, defaults: { format: 'json' } do
    namespace :v1 do
      resource :members, only: [:show]
      resources :proponents, only: %i[index update create destroy show] do
        collection do
          get :report
        end
      end

      resources :inss_calculations, only: [] do
        collection do
          post :discount
        end
      end
    end
  end

  get '*path', to: 'pages#home', constraints: ->(req) { !req.xhr? && req.format.html? }
end
