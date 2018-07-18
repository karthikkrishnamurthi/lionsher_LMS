class AddIsScormToCourses < ActiveRecord::Migration
  def self.up
    add_column :courses, :is_scorm, :boolean, :default => true
  end

  def self.down
  end
end
