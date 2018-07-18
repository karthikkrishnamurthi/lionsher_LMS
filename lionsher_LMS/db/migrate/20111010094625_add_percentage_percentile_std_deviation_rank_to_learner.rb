class AddPercentagePercentileStdDeviationRankToLearner < ActiveRecord::Migration
  def self.up
    add_column :learners, :percentage, :float, :default => 0
    add_column :learners, :percentile, :float, :default => 0
    add_column :learners, :standard_deviation, :float, :default => 0
    add_column :learners, :rank, :integer, :default => 0
  end

  def self.down
  end
end
