class CreateAssessmentQuestions < ActiveRecord::Migration
  def self.up
    create_table :assessment_questions do |t|
      t.integer :assessment_id
      t.integer :question_id
      t.float :mark

      t.timestamps
    end
  end

  def self.down
    drop_table :assessment_questions
  end
end
