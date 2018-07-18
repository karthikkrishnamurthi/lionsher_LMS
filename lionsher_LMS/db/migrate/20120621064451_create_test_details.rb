class CreateTestDetails < ActiveRecord::Migration
  def change
    create_table :test_details do |t|
      t.integer :learner_id
      t.string :attempted_status, :default => "unanswered"
      t.integer :question_bank_id
      t.integer :question_id
      t.integer :answer_id
      t.string :question_type
      t.string :learner_answer_text
      t.string :answer_status
      t.integer :user_id
      t.integer :tenant_id
      t.float :duration_spent, :default => 0
      t.float :score, :default => 0
      t.timestamps
    end
  end
end
