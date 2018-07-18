class AddLearnerTableDetailsToCoursesAndAssessments < ActiveRecord::Migration
  def self.up
    add_column :assessments, :current_learner_id, :integer
    add_column :assessments, :total_learners, :integer, :default => 0
    add_column :assessments, :no_of_attempted_learners, :integer, :default => 0

    add_column :courses, :total_learners, :integer, :default => 0
    add_column :courses, :completed_learners, :integer, :default => 0
    add_column :courses, :no_of_comments, :integer, :default => 0
    add_column :courses, :average_rating, :float, :default => 0.0
  end

  def self.down
  end
end
