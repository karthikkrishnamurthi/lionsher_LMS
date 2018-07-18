class CreateCalculatedDataLearnerAssessments < ActiveRecord::Migration
  def change
    create_table :calculated_data_learner_assessments do |t|
      t.integer :learner_id
      t.integer :user_id
      t.integer :tenant_id
      t.integer :assessment_id
      t.integer :answered, :default => 0
      t.integer :answered_correct, :default => 0
      t.integer :answered_wrong, :default => 0
      t.integer :questions_marked, :default => 0
      t.float :total_score, :default => 0
      t.string :total_time, :default => 0
      t.float :percentage, :default => 0
      t.float :percentile, :default => 0
      t.integer :rank, :default => 0

      t.timestamps
    end
  end
end
