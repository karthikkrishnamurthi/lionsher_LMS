class AddSectionIdToTestDetails < ActiveRecord::Migration
  def change
  	add_column	:test_details,	:section_id,	:integer
  end
end
