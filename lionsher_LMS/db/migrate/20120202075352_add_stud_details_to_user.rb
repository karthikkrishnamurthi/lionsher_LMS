class AddStudDetailsToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :student_course, :string
    add_column :users, :student_course_year, :string
    add_column :users, :student_college, :string
    add_column :users, :student_college_city, :string
  end

  def self.down
  end
end
