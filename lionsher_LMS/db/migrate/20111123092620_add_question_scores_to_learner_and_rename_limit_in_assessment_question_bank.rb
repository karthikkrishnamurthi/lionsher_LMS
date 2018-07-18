class AddQuestionScoresToLearnerAndRenameLimitInAssessmentQuestionBank < ActiveRecord::Migration
  def self.up
    add_column :learners, :question_scores, :text
    rename_column :assessments_question_banks, :limit, :question_limit
    rename_column :questions, :score, :no_of_characters
  end

  def self.down
  end
end
