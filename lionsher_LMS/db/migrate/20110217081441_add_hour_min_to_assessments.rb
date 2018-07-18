class AddHourMinToAssessments < ActiveRecord::Migration
  def self.up
    remove_column :assessments, :duration
    add_column :assessments, :duration_hour, :integer, :default => 0
    add_column :assessments, :duration_min, :integer, :default => 30
  end

  def self.down
  end
end
