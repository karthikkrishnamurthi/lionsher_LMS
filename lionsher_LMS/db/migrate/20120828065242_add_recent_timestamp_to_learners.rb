class AddRecentTimestampToLearners < ActiveRecord::Migration
  def change
  	add_column	:learners, :recent_timestamp, :datetime
  end
end
