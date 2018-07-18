class AddQuestionStatusDetailsToLearner < ActiveRecord::Migration
  def self.up
    add_column :learners, :question_status_details, :text
  end

  def self.down
  end
end
