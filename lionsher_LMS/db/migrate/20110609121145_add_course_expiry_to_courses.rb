class AddCourseExpiryToCourses < ActiveRecord::Migration
  def self.up
    add_column :courses, :course_expiry, :bigint, :default => 1
  end

  def self.down
  end
end
