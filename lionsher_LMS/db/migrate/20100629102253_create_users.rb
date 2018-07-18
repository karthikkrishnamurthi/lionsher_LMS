class CreateUsers < ActiveRecord::Migration
  def self.up
     create_table :users do |t|
      t.column :login,                     :string
      t.column :email,                     :string
      t.column :crypted_password,          :string, :limit => 40
      t.column :created_at,                :datetime
      t.column :updated_at,                :datetime
      t.column :remember_token,            :string
      t.column :remember_token_expires_at, :datetime
      t.column :activation_code,           :string, :limit => 40
      t.column :activated_at,              :datetime
      t.column :reset_code,                :string
      t.column :typeofuser,                :string
      t.column :user_id,                   :integer
      t.column :designation, 		   :string
      t.column :department, 		   :string
      t.column :off_number, 		   :string
      t.column :mob_number, 		   :string
    end
  end

  def self.down
    drop_table :users
  end
end
