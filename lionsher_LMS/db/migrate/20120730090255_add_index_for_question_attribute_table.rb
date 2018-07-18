class AddIndexForQuestionAttributeTable < ActiveRecord::Migration
  def up
    add_index :question_attributes, :question_id, :name => 'ques_attr_question_id_index'
    add_index :question_attributes, :question_bank_id, :name => 'ques_attr_question_bank_id_index'
    add_index :question_attributes, :question_type_id, :name => 'ques_attr_question_type_id_index'
    add_index :question_attributes, :question_status_id, :name => 'ques_attr_question_status_id_index'
    add_index :question_attributes, :tenant_id, :name => 'ques_attr_tenant_id_index'
    add_index :question_attributes, :topic_id, :name => 'ques_attr_topic_id_index'
    add_index :question_attributes, :subtopic_id, :name => 'ques_attr_subtopic_id_index'
    add_index :question_attributes, :direction_id, :name => 'ques_attr_direction_id_index'
    add_index :question_attributes, :passage_id, :name => 'ques_attr_passage_id_index'
    add_index :question_attributes, :difficulty_id, :name => 'ques_attr_difficulty_id_index'
    add_index :question_attributes, :error_id, :name => 'ques_attr_error_id_index'
  end

  def down
  end
end
