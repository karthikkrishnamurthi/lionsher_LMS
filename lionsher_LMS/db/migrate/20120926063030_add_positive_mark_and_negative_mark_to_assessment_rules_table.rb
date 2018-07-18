class AddPositiveMarkAndNegativeMarkToAssessmentRulesTable < ActiveRecord::Migration
  def change
  	add_column	:assessment_rules, :positive_mark, :float, :default => 1
  	add_column	:assessment_rules, :negative_mark, :float, :default => 0
  end
end
