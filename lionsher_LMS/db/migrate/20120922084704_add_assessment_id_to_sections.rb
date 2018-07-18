class AddAssessmentIdToSections < ActiveRecord::Migration
  def change
  	add_column	:sections,	:assessment_id,	:integer
  	add_column	:assessment_rules,	:section_id,	:integer
  end
end
