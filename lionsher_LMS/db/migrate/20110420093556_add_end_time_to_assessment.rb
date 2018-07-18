class AddEndTimeToAssessment < ActiveRecord::Migration
  @time = Time.now.getutc
  def self.up
    add_column :assessments, :end_time, :datetime, :default => @time
  end

  def self.down
  end
end
