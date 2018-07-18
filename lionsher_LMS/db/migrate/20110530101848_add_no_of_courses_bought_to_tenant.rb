class AddNoOfCoursesBoughtToTenant < ActiveRecord::Migration
  def self.up
    add_column :tenants , :no_of_courses_bought ,:integer, :default => 0
    add_column :tenants , :no_of_license ,:integer, :default => 0
  end

  def self.down
  end
end
