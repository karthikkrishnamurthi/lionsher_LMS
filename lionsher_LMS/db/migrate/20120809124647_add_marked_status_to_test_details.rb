class AddMarkedStatusToTestDetails < ActiveRecord::Migration
  def change
  	add_column	:test_details,	:marked_status, :string, :default => "unmarked"
  end
end
