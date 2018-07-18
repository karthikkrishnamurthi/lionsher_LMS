class CreateLearnerQuestions < ActiveRecord::Migration
  def self.up
    create_table :learner_questions do |t|
      t.integer :learner_id
      t.integer :user_id
      t.integer :assessment_id
      t.integer :question_bank_id
      t.integer :question_id
      t.string :answer
      t.float :score
      t.string :answer_status
      t.string :attempted_status
      t.integer :duration
      t.integer :tenant_id

      t.timestamps
    end
  end

  def self.down
    drop_table :learner_questions
  end
end
