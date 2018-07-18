class AddTypeOfTestTakerToLearners < ActiveRecord::Migration
  def self.up
    add_column :learners ,  :type_of_test_taker,  :string,  :default => 'admin'
  end

  def self.down
  end
end
