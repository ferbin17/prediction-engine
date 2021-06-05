Prediction::Engine.routes.draw do
  resources :users, only: [] do
    collection do
      get 'login'
      post 'login'
      get 'logout'
      get 'change_password'
      post 'change_password'
    end
  end
  
  resources :predictions, only: [] do
    collection do
      get 'predict'
      post 'predict'
      get 'match_popup'
      get 'table'
    end
  end
  
  resources :settings, only: [:index] do
    collection do
      get 'create_competetion'
      post 'create_competetion'
    end
    
    member do
      get 'edit_competetion'
      post 'edit_competetion'
      get 'change_competetion_status'
      delete 'delete_competetion'
      get 'create_phase'
      post 'create_phase'
      get 'edit_phase'
      post 'edit_phase'
      delete 'delete_phase'
      get 'confirm_phase'
      get 'create_match'
      post 'create_match'
    end
  end
  
  root to: "predictions#predict"
end
