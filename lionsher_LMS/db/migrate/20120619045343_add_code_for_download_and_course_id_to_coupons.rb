class AddCodeForDownloadAndCourseIdToCoupons < ActiveRecord::Migration
  def change
    add_column :coupons, :code_for_download, :string
    add_column :coupons, :course_id, :integer
  end
end
