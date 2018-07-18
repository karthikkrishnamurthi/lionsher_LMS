class AddGroupIdToUsers < ActiveRecord::Migration
  def self.up
    add_column :users , :group_id, :integer , :default => 1
  end

  def self.down
  end
end
