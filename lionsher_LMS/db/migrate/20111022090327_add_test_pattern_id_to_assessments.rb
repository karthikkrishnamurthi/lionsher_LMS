class AddTestPatternIdToAssessments < ActiveRecord::Migration
  def self.up
    add_column :assessments, :test_pattern_id, :integer
  end

  def self.down
  end
end
