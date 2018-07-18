class CreateDescriptiveAnswers < ActiveRecord::Migration
  def self.up
    create_table :descriptive_answers do |t|
      t.text :answer
      t.integer :learner_id
      t.integer :question_id
      t.integer :user_id
      t.integer :admin_id
      t.integer :assessment_id
      t.float :marks

      t.timestamps
    end
  end

  def self.down
    drop_table :descriptive_answers
  end
end
