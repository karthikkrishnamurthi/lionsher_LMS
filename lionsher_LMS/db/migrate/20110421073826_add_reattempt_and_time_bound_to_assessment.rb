class AddReattemptAndTimeBoundToAssessment < ActiveRecord::Migration
  def self.up
    add_column :assessments, :reattempt, :string, :default => "on"
    add_column :assessments, :time_bound, :string
  end

  def self.down
  end
end
