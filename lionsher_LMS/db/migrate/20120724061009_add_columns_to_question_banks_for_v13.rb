class AddColumnsToQuestionBanksForV13 < ActiveRecord::Migration
  def change
  	add_column	:question_banks, :type_of_question_bank, :string
  	add_column	:question_banks, :tenant_id, :integer
  end
end
