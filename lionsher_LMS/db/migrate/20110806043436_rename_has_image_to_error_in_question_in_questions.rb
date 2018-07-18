class RenameHasImageToErrorInQuestionInQuestions < ActiveRecord::Migration
  def self.up
    rename_column :questions, :has_image, :error_in_question
  end

  def self.down
  end
end
