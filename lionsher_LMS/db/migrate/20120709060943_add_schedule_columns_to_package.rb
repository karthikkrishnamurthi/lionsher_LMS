class AddScheduleColumnsToPackage < ActiveRecord::Migration
  def change
    add_column  :packages, :schedule_type, :string,  :default => "open"
    add_column  :packages, :start_time,  :datetime,  :default => Time.now.utc
    add_column  :packages, :end_time, :datetime, :default => Time.now.utc
    add_column  :packages, :reattempt, :string, :default => "on"
    add_column  :packages, :time_bound, :string
  end
end
