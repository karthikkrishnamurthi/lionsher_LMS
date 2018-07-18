class AddImageToAssessments < ActiveRecord::Migration
  def change
    add_column  :assessments, :assessment_image_file_name, :string
    add_column  :assessments, :assessment_image_content_type, :string
    add_column  :assessments, :assessment_image_file_size, :integer
  end
end
