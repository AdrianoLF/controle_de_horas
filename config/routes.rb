Rails.application.routes.draw do
  devise_for :users,
             controllers: {
               sessions: 'users/sessions',
               registrations: 'users/registrations'
             }

  root 'pages#home'
  namespace :api, defaults: { format: 'json' } do
    namespace :v1 do
      resources :members, only: %i[index update create destroy show]
      
      resources :teams, only: %i[index update create destroy show] do
        resources :memberships, only: %i[create destroy]
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
