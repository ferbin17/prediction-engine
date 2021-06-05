Rails.application.routes.draw do
  mount Prediction::Engine => "/prediction"
end
