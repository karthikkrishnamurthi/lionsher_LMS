class AddCourseStoreColumnsToCourses < ActiveRecord::Migration
  def self.up
    add_column :courses , :course_objective ,:string
    add_column :courses , :learners_type ,:string
    add_column :courses , :domain ,:string
    add_column :courses , :keywords ,:string
    add_column :courses , :course_price ,:string
    add_column :courses , :lms_cs ,:string
    add_column :courses , :course_library ,:string
  end

  def self.down
  end
end
