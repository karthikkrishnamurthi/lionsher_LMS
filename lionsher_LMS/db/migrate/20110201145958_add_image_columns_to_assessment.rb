class AddImageColumnsToAssessment < ActiveRecord::Migration
  def self.up
    add_column :questions, :image_file_name, :string
    add_column :questions, :image_content_type, :string
    add_column :questions, :image_file_size, :integer
  end

  def self.down
  end
end
