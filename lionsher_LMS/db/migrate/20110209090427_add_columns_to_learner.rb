class AddColumnsToLearner < ActiveRecord::Migration
  def self.up
    add_column :learners, :set_1, :integer, :default => 0
    add_column :learners, :set_2, :integer, :default => 0
    add_column :learners, :set_3, :integer, :default => 0
    add_column :learners, :set_4, :integer, :default => 0
    add_column :learners, :set_5, :integer, :default => 0
  end

  def self.down
  end
end
