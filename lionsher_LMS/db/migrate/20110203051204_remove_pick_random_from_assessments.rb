class RemovePickRandomFromAssessments < ActiveRecord::Migration
  def self.up
    remove_column :assessments, :pick_random
  end

  def self.down
  end
end
