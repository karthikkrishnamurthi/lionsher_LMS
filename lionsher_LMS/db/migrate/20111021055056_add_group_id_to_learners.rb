class AddGroupIdToLearners < ActiveRecord::Migration
  def self.up
    add_column :learners, :group_id, :integer, :default => 1
  end

  def self.down
  end
end
