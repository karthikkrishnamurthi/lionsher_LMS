class AddCurrentLearnerIdToCourses < ActiveRecord::Migration
  def change
    add_column  :courses, :current_learner_id, :integer
  end
end
