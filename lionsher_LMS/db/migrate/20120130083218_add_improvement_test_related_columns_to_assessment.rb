class AddImprovementTestRelatedColumnsToAssessment < ActiveRecord::Migration
  def self.up
    add_column  :assessments, :allow_improvement, :boolean, :default => true
    add_column  :assessments, :no_of_questions_in_improvement_test, :integer, :default => 0
    add_column  :assessments, :is_overall, :boolean, :default => true
    add_column  :assessments, :overall_less_percentage, :integer, :default => 0
    add_column  :assessments, :section_less_percentage, :integer, :default => 0
  end

  def self.down
  end
end
