class AddScheduleTypeStartTimeEndTimeReattemptToCourses < ActiveRecord::Migration
  def self.up
    add_column :courses, :schedule_type, :string, :default => "open"
    add_column :courses, :start_time, :datetime, :default => Time.now.utc
    add_column :courses, :end_time, :datetime, :default => Time.now.utc
    add_column :courses, :reattempt, :string, :default => "on"
  end

  def self.down
  end
end
