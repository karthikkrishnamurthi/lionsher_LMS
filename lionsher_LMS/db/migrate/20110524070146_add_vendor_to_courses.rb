class AddVendorToCourses < ActiveRecord::Migration
  def self.up
    add_column :courses, :vendor, :string, :default => "LionSher"
    add_column :courses, :duration_hour, :integer
    add_column :courses, :duration_min, :integer
  end

  def self.down
  end
end
