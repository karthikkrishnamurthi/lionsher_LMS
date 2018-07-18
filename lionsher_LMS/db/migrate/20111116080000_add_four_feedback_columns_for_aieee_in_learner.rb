class AddFourFeedbackColumnsForAieeeInLearner < ActiveRecord::Migration
  def self.up
    add_column :learners, :enjoy_experience_answer, :string
    add_column :learners, :time_alloted_answer, :string
    add_column :learners, :suggest_a_question, :text
    add_column :learners, :suggestions_for_improvement, :text
  end

  def self.down
  end
end
