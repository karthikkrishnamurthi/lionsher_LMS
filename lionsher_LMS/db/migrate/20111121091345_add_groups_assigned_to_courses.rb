class AddGroupsAssignedToCourses < ActiveRecord::Migration
  def self.up
    add_column :courses, :groups_assigned, :string
  end

  def self.down
  end
end
