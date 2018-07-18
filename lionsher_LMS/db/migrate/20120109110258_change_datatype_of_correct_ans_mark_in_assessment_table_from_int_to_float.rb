class ChangeDatatypeOfCorrectAnsMarkInAssessmentTableFromIntToFloat < ActiveRecord::Migration
  def self.up
	change_column :assessments, :correct_ans_points, :float, :default => 1
  end

  def self.down
  end
end
