class AddAnswerImageToAnswers < ActiveRecord::Migration
  def self.up
    add_column :answers ,  :answer_image_file_name,  :string
    add_column :answers ,  :answer_image_content_type,  :string
    add_column :answers ,  :answer_image_file_size,  :integer
  end

  def self.down
  end
end
