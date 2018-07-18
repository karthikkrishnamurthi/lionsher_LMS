class AddNoOfReattemptsToCourses < ActiveRecord::Migration
  def self.up
    add_column  :courses, :no_of_reattempts, :integer, :default => 30
  end

  def self.down
  end
end
