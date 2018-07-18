class AddNoOfTimesAttemptedToLearner < ActiveRecord::Migration
  def self.up
    add_column :learners, :no_of_times_attempted, :integer, :default => 0
  end

  def self.down
  end
end
