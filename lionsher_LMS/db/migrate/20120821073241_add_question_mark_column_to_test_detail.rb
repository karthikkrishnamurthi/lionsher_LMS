class AddQuestionMarkColumnToTestDetail < ActiveRecord::Migration
  def change
  	add_column :test_details, :question_positive_mark, :float
  	add_column :test_details, :question_negative_mark, :float
  end
end
