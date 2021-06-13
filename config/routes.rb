Prediction::Engine.routes.draw do
  resources :users do
    collection do
      get 'login'
      post 'login'
      get 'logout'
      get 'approval'
      post 'approval'
      get 'login_requests'
    end
    
    member do
      get 'profile'
      get 'change_password'
      post 'change_password'
      get 'reset_password'
    end
  end
  
  resources :predictions, only: [] do
    collection do
      get 'predict'
      post 'predict'
      get 'match_popup'
      get 'table'
      get 'rules'
    end
  end
  
  resources :settings, only: [:index] do  
    member do
      get 'create_match'
      post 'create_match'
    end
  end
  
  resources :competetions, except: [:index] do
    member do
      get 'confirm_competetion'
    end
  end
  
  resources :phases, except: [:index] do
    member do
      get 'confirm_phase'
    end
  end
  
  resources :matches, except: [:index, :show] do
    member do
      get 'confirm_match'
      get 'end_match'
      get 'submit_score'
      patch 'submit_score'
      get 'calculate_score'
    end
  end
  
  root to: "predictions#predict"
end
