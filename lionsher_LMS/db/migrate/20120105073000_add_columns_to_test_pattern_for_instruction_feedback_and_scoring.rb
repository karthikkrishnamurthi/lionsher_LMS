class AddColumnsToTestPatternForInstructionFeedbackAndScoring < ActiveRecord::Migration
  def self.up
    add_column :test_patterns, :feedback, :boolean
    add_column :test_patterns, :correct_mark, :float, :default => 1
    add_column :test_patterns, :wrong_mark, :float, :default => 0    
  end

  def self.down
  end
end
