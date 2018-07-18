class CreateCalculatedDataAssessments < ActiveRecord::Migration
  def change
    create_table :calculated_data_assessments do |t|
      t.integer :assessment_id
      t.integer :tenant_id
      t.integer :started, :default => 0
      t.integer :in_process, :default => 0
      t.integer :completed, :default => 0
      t.integer :timed_out, :default => 0
      t.integer :incomplete, :default => 0
      t.float :lowest_score, :default => 0
      t.float :highest_score, :default => 0
      t.float :average_score, :default => 0
      t.float :sd_score, :default => 0
      t.string :lowest_time
      t.string :highest_time
      t.string :average_time

      t.timestamps
    end
  end
end
