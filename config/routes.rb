TapasEngine::Engine.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  root 'application#index'

  resources :dingding_users
end
