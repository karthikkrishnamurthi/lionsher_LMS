class ChangeImageToPackageImage < ActiveRecord::Migration
  def up
    remove_column :packages, :image_file_name
    remove_column :packages, :image_content_type
    remove_column :packages, :image_file_size
    add_column :packages, :package_image_file_name, :string
    add_column :packages, :package_image_content_type, :string
    add_column :packages, :package_image_file_size, :integer
  end

  def down
  end
end
