class CreateEmails < ActiveRecord::Migration
  def self.up
    create_table :emails do |t|
      t.string :email_type
      t.string :from
      t.string :subject
      t.text :body
      t.integer :tenant_id
      t.integer :user_id
      t.boolean :is_parsed, :default=> false

      t.timestamps
    end
  end

  def self.down
    drop_table :emails
  end
end
