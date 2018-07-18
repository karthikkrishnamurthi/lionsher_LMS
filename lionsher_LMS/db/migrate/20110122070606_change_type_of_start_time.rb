class ChangeTypeOfStartTime < ActiveRecord::Migration
  def self.up
	remove_column :assessments, :date
	remove_column :assessments, :am_pm
    change_column :assessments, :start_time, :datetime    
  end

  def self.down
  end
end
