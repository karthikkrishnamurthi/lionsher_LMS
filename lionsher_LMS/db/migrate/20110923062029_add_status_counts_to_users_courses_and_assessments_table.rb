class AddStatusCountsToUsersCoursesAndAssessmentsTable < ActiveRecord::Migration
  def self.up
    add_column :courses, :incomplete_learners, :integer, :default => 0
    add_column :courses, :unattempted_learners, :integer, :default => 0
    add_column :courses, :timeup_learners, :integer, :default => 0

    add_column :assessments, :completed_learners, :integer, :default => 0
    add_column :assessments, :incomplete_learners, :integer, :default => 0
    add_column :assessments, :unattempted_learners, :integer, :default => 0
    add_column :assessments, :timeup_learners, :integer, :default => 0

    add_column :users, :no_of_courses_assigned, :integer, :default => 0
    add_column :users, :no_of_assessments_assigned, :integer, :default => 0
    add_column :users, :completed, :integer, :default => 0
    add_column :users, :incomplete, :integer, :default => 0
    add_column :users, :unattempted, :integer, :default => 0
    add_column :users, :timeup, :integer, :default => 0

    rename_column :learners, :user_id, :admin_id
    rename_column :learners, :learners_ID, :user_id
  end

  def self.down
  end
end
