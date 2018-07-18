class AddLinearRandomToAssessments < ActiveRecord::Migration
  def self.up
    add_column :assessments ,  :is_linear,  :boolean, :default => false
  end

  def self.down
  end
end
