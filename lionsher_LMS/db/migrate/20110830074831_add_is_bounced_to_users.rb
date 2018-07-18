class AddIsBouncedToUsers < ActiveRecord::Migration
  def self.up
    add_column :users ,  :is_bounced, :boolean, :default => false
  end

  def self.down
  end
end
