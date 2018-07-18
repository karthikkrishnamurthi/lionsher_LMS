class ChangeImageColumnInQuestions < ActiveRecord::Migration
  def self.up
    rename_column :questions, :image_file_name, :question_image_file_name
    rename_column :questions, :image_content_type, :question_image_content_type
    rename_column :questions, :image_file_size, :question_image_file_size
  end

  def self.down
  end
end
