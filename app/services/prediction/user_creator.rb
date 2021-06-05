require_relative "application_service"

module Prediction
  class UserCreator < ApplicationService
    def initialize(name, username, phone)
      @full_name = name
      @username = username
      @phone = phone
      @log = Logger.new('log/user_creation.log')
      @log.info "-------------------------------------------"
    end
    
    def call
      password = "#{(0...5).map { ('a'..'z').to_a[rand(26)] }.join}@footyboyz"
      @log.info "Creating user with data - Name: #{@full_name}, Username: #{@username}, Phone: #{@phone}, Password: #{password}"
      user = User.new(full_name: @full_name, username: @username, phone_no: @phone, password: password)
      if user.save
        @log.info "User created"
      else
        @log.info "User creation failed due to #{user.errors.full_messages}"
      end
      @log.info "-------------------------------------------"
    end
  end
end