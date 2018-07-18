class AddAssessmentScoreToLearners < ActiveRecord::Migration
  def self.up
    add_column  :learners, :assessment_score, :float, :default => 0
  end

  def self.down
  end
end
