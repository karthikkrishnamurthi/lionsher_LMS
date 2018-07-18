class ChangeTypeOfDatatypeForAttemptedUnattemptedAndIncompleteInLearners < ActiveRecord::Migration
  def self.up
    change_column :learners, :marked_questions, :text
    change_column :learners, :incomplete_questions, :text
    change_column :learners, :attempted_questions, :text
  end

  def self.down
  end
end
