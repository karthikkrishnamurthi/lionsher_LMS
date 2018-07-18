class AddTypeOfInvigilatorToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :type_of_evaluator, :string
    add_column :questions, :type_of_dtq, :string
  end

  def self.down
  end
end
