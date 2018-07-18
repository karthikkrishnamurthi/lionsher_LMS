class AddIsShowAllInAssessments < ActiveRecord::Migration
  def self.up
    add_column :assessments, :is_show_all, :boolean, :default => true
  end

  def self.down
  end
end
