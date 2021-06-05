class CreatePredictionUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :prediction_users do |t|
      t.string :full_name
      t.string :username, index: true
      t.string :password_salt
      t.string :hashed_password
      t.boolean :first_login, default: true
      t.string :phone_no
      t.integer :total_point, default: 0
      t.boolean :is_admin, default: false
      t.boolean :is_active, default: true
      t.boolean :is_deleted, default: false
      t.timestamps
    end
  end
end
