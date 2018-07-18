class AddShowQuestionLayoutRelatedColumnToAssessment < ActiveRecord::Migration
  def change
    add_column :assessments, :show_all_per_page, :boolean, :default => false
  end
end
