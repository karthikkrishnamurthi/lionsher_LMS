class CreateAssessments < ActiveRecord::Migration
  def self.up
    create_table :assessments do |t|
      t.string :name
      t.text :description
      t.date :date
      t.string :start_time
      t.string :am_pm
      t.string :duration
      t.integer :correct_ans_points
      t.integer :wrong_ans_points
      t.string :random_answers
      t.string :pick_random
      t.integer :no_of_questions
      t.timestamps
    end
  end

  def self.down
    drop_table :assessments
  end
end
