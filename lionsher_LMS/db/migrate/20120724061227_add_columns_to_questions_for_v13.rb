class AddColumnsToQuestionsForV13 < ActiveRecord::Migration
  def change
  	rename_column	:questions, :question, :question_text
  	add_column	:questions, :expiry_date, :datetime
  	add_column	:questions, :tenant_id, :integer
  end
end
