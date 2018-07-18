class CreateTenants < ActiveRecord::Migration
  def self.up
    create_table :tenants do |t|
      t.string :organization
      t.string :logo_file_name
      t.string :logo_content_type
      t.integer :logo_file_size
      t.integer :user_id
      t.string :theme, :default => "gray"
      t.string :text_color, :default => "orange"
      t.string :custom_url
      t.string :quarter, :default => 'Current Quarter(Q4)'
      t.timestamps
    end
  end

  def self.down
    drop_table :tenants
  end
end
