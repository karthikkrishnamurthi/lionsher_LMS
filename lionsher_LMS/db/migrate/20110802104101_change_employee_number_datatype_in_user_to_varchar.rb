class ChangeEmployeeNumberDatatypeInUserToVarchar < ActiveRecord::Migration
  def self.up
    change_column :users, :employee_number, :string
  end

  def self.down
  end
end
