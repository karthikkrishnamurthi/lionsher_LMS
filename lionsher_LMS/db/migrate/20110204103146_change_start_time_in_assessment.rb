class ChangeStartTimeInAssessment < ActiveRecord::Migration
  @time = Time.now.getutc
  def self.up
    change_column :assessments, :start_time, :datetime, :default => @time
  end

  def self.down
  end
end
