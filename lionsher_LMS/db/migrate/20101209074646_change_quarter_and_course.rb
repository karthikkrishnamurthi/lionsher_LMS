class ChangeQuarterAndCourse < ActiveRecord::Migration
  def self.up
    change_column :tenants, :quarter, :string
    change_column :courses, :description, :text, :default=>""
  end

  def self.down
  end
end
