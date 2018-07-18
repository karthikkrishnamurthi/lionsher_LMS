class AddGroupsAssignedToAssessments < ActiveRecord::Migration
  def self.up
    add_column :assessments, :groups_assigned, :string
  end

  def self.down
  end
end
