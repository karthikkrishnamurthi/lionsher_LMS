class Changecolumnassess < ActiveRecord::Migration
  def self.up
    change_column :assessments, :correct_ans_points, :integer, :default => 1
    change_column :assessments, :wrong_ans_points, :integer, :default => 0
    change_column :assessments, :am_pm, :string, :default => "am"
  end

  def self.down
  end
end
