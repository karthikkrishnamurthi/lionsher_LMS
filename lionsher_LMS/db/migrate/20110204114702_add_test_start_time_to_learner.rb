class AddTestStartTimeToLearner < ActiveRecord::Migration
  @time = Time.now.getutc
  def self.up
    add_column :learners, :test_start_time, :datetime, :default => @time
  end

  def self.down
  end
end
