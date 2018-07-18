class AddColumnsToAnswersForV13 < ActiveRecord::Migration
  def change
  	rename_column	:answers, :answer, :answer_text
  	rename_column	:answers, :status, :answer_status
  	add_column	:answers, :tenant_id, :integer
  end
end
