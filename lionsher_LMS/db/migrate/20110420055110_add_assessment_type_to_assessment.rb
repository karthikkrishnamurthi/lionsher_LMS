class AddAssessmentTypeToAssessment < ActiveRecord::Migration
  def self.up
    add_column  :assessments, :assessment_type, :string, :default => "multiple"
  end

  def self.down
  end
end
