class AddTopicWiseRankPercentageAndPercentileToLearner < ActiveRecord::Migration
  def self.up
    add_column :learners, :topic_wise_rank, :integer
    add_column :learners, :topic_wise_percentile, :integer
  end

  def self.down
  end
end
