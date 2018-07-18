class CreateIndexesOnTestDetails < ActiveRecord::Migration
  def up
  	add_index :test_details, :learner_id, :name => 'learner_id_on_test_details'
    add_index :test_details, :question_bank_id, :name => 'question_bank_id_on_test_details'
    add_index :test_details, :question_id, :name => 'question_id_on_test_details'
    add_index :test_details, :answer_id, :name => 'answer_id_on_test_details'
    add_index :test_details, :tenant_id, :name => 'tenant_id_on_test_details'
    add_index :test_details, :user_id, :name => 'user_id_on_test_details'
    add_index :test_details, :attempted_status, :name => 'attempted_status_on_test_details'
    add_index :test_details, :marked_status, :name => 'marked_status_on_test_details'
    add_index :test_details, :answer_status, :name => 'answer_status_on_test_details'
  end

  def down
  end
end
