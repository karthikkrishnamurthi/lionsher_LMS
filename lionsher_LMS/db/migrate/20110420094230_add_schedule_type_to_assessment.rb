class AddScheduleTypeToAssessment < ActiveRecord::Migration
  def self.up
    add_column :assessments, :schedule_type, :string, :default => "open"
  end

  def self.down
  end
end
