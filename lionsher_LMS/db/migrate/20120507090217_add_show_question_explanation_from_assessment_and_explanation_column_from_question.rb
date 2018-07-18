class AddShowQuestionExplanationFromAssessmentAndExplanationColumnFromQuestion < ActiveRecord::Migration
  def change
    add_column  :assessments, :show_question_explanation, :boolean, :dafault => false
    Assessment.reset_column_information
    Assessment.update_all ["show_question_explanation = ?", false]
    add_column  :questions, :explanation, :text, :dafault => ""
    Question.reset_column_information
    Question.update_all ["explanation = ?", ""]
  end
end
