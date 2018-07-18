class CreateLearners < ActiveRecord::Migration
  def self.up
    create_table :learners do |t|
      t.integer :user_id
      t.integer :learners_ID
      t.integer :course_id
      t.integer :tenant_id
      t.string  :lesson_location, :default => ""
      t.string  :credit, :default => "credit"
      t.string  :entry, :default => "ab-initio"
      t.string  :exit
      t.string  :lesson_status, :default => "not attempted"
      t.string  :lesson_mode, :default => "normal"
      t.string  :score_raw, :default => ""
      t.string  :score_max, :default => ""
      t.string  :score_min, :default => ""
      t.string  :total_time, :default => "0000:00:00.00"
      t.string  :session_time
      t.string  :suspend_data, :default => ""
      t.string  :launch_data, :default => ""
      t.integer :rating, :default => 0
      t.text    :comments
      t.timestamps
    end
  end

  def self.down
    drop_table :learners
  end
end
