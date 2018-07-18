class AddMarkedIncompleteAndAttemptedQuestionsColumnToLearners < ActiveRecord::Migration
  def self.up
    add_column :learners, :marked_questions, :string
    add_column :learners, :incomplete_questions, :string
    add_column :learners, :attempted_questions, :string
  end

  def self.down
  end
end
