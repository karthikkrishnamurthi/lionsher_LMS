class RemoveSetsFromLearners < ActiveRecord::Migration
  def self.up
    remove_column :learners,  :set_1
    remove_column :learners,  :set_2
    remove_column :learners,  :set_3
    remove_column :learners,  :set_4
    remove_column :learners,  :set_5
  end

  def self.down
  end
end
