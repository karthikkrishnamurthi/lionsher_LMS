class AddQuestionBankIdQuestionTypeIdAndDifficultyIdToRulesTable < ActiveRecord::Migration
  def change
  	add_column	:assessment_rules, :question_bank_id, :integer
  	add_column	:assessment_rules, :question_type_id, :integer
  	add_column	:assessment_rules, :difficulty_id, :integer
  end
end
