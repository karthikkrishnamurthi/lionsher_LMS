class AddNegativeMarkColumnToAssessmentQuestion < ActiveRecord::Migration
  def change
    add_column  :assessment_questions, :negative_mark, :float, :default => 0
  end
end
