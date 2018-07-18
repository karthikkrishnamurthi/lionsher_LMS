class ChangeTypeOfSuspendLaunchColumns < ActiveRecord::Migration
  def self.up
    change_column :learners, :suspend_data, :text, :null => false
    change_column :learners, :launch_data, :text, :null => false
  end

  def self.down
  end
end
