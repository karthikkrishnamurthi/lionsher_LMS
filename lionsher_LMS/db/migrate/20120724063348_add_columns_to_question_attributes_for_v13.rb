class AddColumnsToQuestionAttributesForV13 < ActiveRecord::Migration
  def change
  	remove_column	:question_attributes, :tag_id
  	add_column	:question_attributes, :question_type_id, :integer
  	add_column	:question_attributes, :question_bank_id, :integer
  	add_column	:question_attributes, :topic_id, :integer 
  	add_column	:question_attributes, :subtopic_id, :integer 
  	add_column	:question_attributes, :difficulty_id, :integer
  	add_column	:question_attributes, :direction_id, :integer 
  	add_column	:question_attributes, :passage_id, :integer 
  	add_column	:question_attributes, :error_id, :integer 
  	add_column	:question_attributes, :question_status_id, :integer
  end
end
