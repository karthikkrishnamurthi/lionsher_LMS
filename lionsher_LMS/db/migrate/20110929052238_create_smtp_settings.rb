class CreateSmtpSettings < ActiveRecord::Migration
  def self.up
    create_table :smtp_settings do |t|
      t.string :name
      t.boolean :is_active, :default=> false

      t.timestamps
    end
  end

  def self.down
    drop_table :smtp_settings
  end
end
