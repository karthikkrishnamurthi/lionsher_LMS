class AddSerialNumberInTestDetail < ActiveRecord::Migration
  def up
  	add_column :test_details, :serial_number, :integer
  end

  def down
  end
end
