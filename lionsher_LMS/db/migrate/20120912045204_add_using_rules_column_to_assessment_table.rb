class AddUsingRulesColumnToAssessmentTable < ActiveRecord::Migration
  def change
  	add_column	:assessments, :using_rules, :boolean, :default => false
  end
end
