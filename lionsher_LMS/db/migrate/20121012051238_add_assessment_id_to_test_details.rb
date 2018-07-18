class AddAssessmentIdToTestDetails < ActiveRecord::Migration
  def change
  	add_column	:test_details, :assessment_id, :integer
  end
end
