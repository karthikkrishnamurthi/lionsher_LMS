class AddCummulativeTimeToAssessments < ActiveRecord::Migration
  def self.up
    add_column :assessments ,  :cummulative_time,  :boolean,  :default => false
  end

  def self.down
  end
end
