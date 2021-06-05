# Prediction
\\ In Gemfile
gem 'jwt'
gem 'prediction', path: 'vendor/engines/prediction'

\\ In routes.rb
mount Prediction::Engine => "/"

\\ In terminal
yarn add bootstrap@next
yarn add @popperjs/core
yarn add jquery

\\ In webpack/environment.js
const webpack = require('webpack')
environment.plugins.prepend('Provide',
  new webpack.ProvidePlugin({
    $: 'jquery/src/jquery',
    jQuery: 'jquery/src/jquery'
  })
)

\\ In application.js
require('jquery')
import 'bootstrap/dist/js/bootstrap'
import "bootstrap/dist/css/bootstrap";

\\ In environments/development.rb and environments/production.rb
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  address: Rails.application.credentials.aws[:email_configuratons][:address],
  port: Rails.application.credentials.aws[:email_configuratons][:port],
  domain: Rails.application.credentials.aws[:email_configuratons][:domain],
  user_name: Rails.application.credentials.aws[:email_configuratons][:username],
  password: Rails.application.credentials.aws[:email_configuratons][:password],
  authentication: Rails.application.credentials.aws[:email_configuratons][:authentication]
}

\\ EDITOR="nano" rails credentials:edit
aws:
   email_configuratons:
      address: "smtp.gmail.com"
      port: 587
      domain: "smtp.gmail.com"
      username: "example@gmail.com"
      password: "password"
      authentication: "plain"
      enable_starttls_auto: true
