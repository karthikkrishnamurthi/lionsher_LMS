class CreateTestPatterns < ActiveRecord::Migration
  def self.up
    create_table :test_patterns do |t|
      t.string :pattern_name
      t.boolean :multi_topic
      t.boolean :instructions
      t.boolean :topic_wise_timer
      t.boolean :random_order_questions
      t.boolean :question_wise_scoring
      t.boolean :skip_question
      t.boolean :view_attempted
      t.boolean :view_unattempted
      t.boolean :view_marked
      t.boolean :view_results

      t.timestamps
    end
  end

  def self.down
    drop_table :test_patterns
  end
end
