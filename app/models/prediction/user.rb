module Prediction
  class User < ApplicationRecord
    default_scope -> { where(is_active: true, is_deleted: false) } 
    attr_accessor :password
    has_many :user_predictions, dependent: :destroy
    validates_presence_of :full_name
    validates :username, presence: true, format: { with: /\A[A-Za-z]{1}([A-Za-z0-9]{1}){4,9}([@, _]+[A-Za-z0-9]+\z)*/i }
    validates :phone_no, presence: true, format: { with: /(?:\+?|\b)[0-9]{10}\b/i}, if: Proc.new{|u| !u.is_admin?}
    validates :username, :phone_no, uniqueness: {scope: :is_deleted}
    validates :request_token, uniqueness: {scope: :is_deleted}, if: Proc.new{|u| u.request_token.present?}
    validates_presence_of :password, if: Proc.new{|u| (!u.hashed_password.present? || !u.password_salt.present?)}
    before_save :hash_password, if: Proc.new{|u| u.password.present?}
    scope :active, -> { where(is_active: true) }
    scope :not_deleted, -> { unscoped.where(is_deleted: false)}
    scope :players, -> { where(is_admin: false) }
    scope :login_requested, -> { where("is_active = FALSE AND request_token IS NOT NULL") }
    
    # Fetches predicted mattches in a phase
    def user_predictions_in_phase(phase_id)
      phase = Phase.find_by_id(phase_id)
      if phase
        match_ids = phase.matches.pluck(:id)
        return user_predictions.where(match_id: match_ids).group_by(&:match_id)
      end
      return {}
    end
    
    # Authenticate password
    def authenticate
      user = User.active.where(username: self.username).first
      if user.present?
        return user.hashed_password == Digest::SHA1.hexdigest(user.password_salt.to_s + self.password)
      end
      return false
    end
    
    # Update user total score
    def update_total_score
      sum = user_predictions.calculated_predictions.pluck(:score).sum
      update(total_score: sum)
    end
    
    # Create a new user
    def self.create_player(name, username, phone)
      UserCreator.call(name, username, phone)
    end
    
    # Update default password if new password matches else returns false
    def update_default_password(pass_params)
      if pass_params[:new_password] == pass_params[:confirm_password]
        return "" if hashed_password == Digest::SHA1.hexdigest(password_salt.to_s + pass_params[:new_password])
        self.password = pass_params[:new_password]
        self.first_login = false
        return self.save      
      else
        return false
      end
    end
    
    # Changes the active status
    def toggle_active_status
      self.update(is_active: !self.is_active)
    end
    
    # Generates a unique token for user
    def generate_request_token
      token = "#{(0...3).map { ('a'..'z').to_a[rand(26)] }.join}#{(0...3).map { (0..9).to_a[rand(9)] }.join}"
      while User.exists?(request_token: token)
        token = "#{(0...3).map { ('a'..'z').to_a[rand(26)] }.join}#{(0...3).map { (0..9).to_a[rand(9)] }.join}"
      end
      self.update(request_token: token)
      token
    end
    
    private
      # Hash password before saving
      def hash_password
        self.password_salt =  SecureRandom.base64(8) if self.password_salt.nil?
        self.hashed_password = Digest::SHA1.hexdigest(self.password_salt + self.password)
      end
  end
end
