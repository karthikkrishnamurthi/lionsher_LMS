class AddColumnDeactivatedAtToUsers < ActiveRecord::Migration
  def self.up
	add_column :users, :deactivated_at, :datetime
  end

  def self.down
  end
end
