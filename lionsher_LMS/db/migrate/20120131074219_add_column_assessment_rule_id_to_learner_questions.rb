class AddColumnAssessmentRuleIdToLearnerQuestions < ActiveRecord::Migration
  def self.up
    add_column :learner_questions, :assessment_rule_id, :integer
  end

  def self.down
  end
end
