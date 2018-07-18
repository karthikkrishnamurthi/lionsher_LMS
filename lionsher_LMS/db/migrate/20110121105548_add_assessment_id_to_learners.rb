class AddAssessmentIdToLearners < ActiveRecord::Migration
  def self.up
    add_column :learners, :assessment_id, :integer
  end

  def self.down
  end
end
