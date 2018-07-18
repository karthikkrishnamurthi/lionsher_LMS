class AddTimestampToTestDetails < ActiveRecord::Migration
  def change
  	add_column	:test_details, :timestamp, :datetime
  end
end
