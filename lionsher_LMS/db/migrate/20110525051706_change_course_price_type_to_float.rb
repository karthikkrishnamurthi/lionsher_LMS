class ChangeCoursePriceTypeToFloat < ActiveRecord::Migration
  def self.up
    change_column :courses, :course_price, :float
  end

  def self.down
  end
end
