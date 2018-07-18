class AddShowQuestionWiseScoringToAssessmentTable < ActiveRecord::Migration
  def self.up
	add_column :assessments, :show_question_wise_scoring, :string, :default => "off"
  end

  def self.down
  end
end
