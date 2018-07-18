class ChangeCourseExpiryDefaultValueInCourses < ActiveRecord::Migration
  def self.up
    change_column :courses, :course_expiry, :boolean, :default => false
    Course.reset_column_information
    Course.update_all ["course_expiry = ?", false]
  end

  def self.down
  end
end
