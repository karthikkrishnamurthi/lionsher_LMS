class AddSectionStartTimeToTestDetails < ActiveRecord::Migration
  def change
    add_column :test_details, :section_start_time, :datetime
  end
end
