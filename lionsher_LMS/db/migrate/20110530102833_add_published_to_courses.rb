class AddPublishedToCourses < ActiveRecord::Migration
  def self.up
    add_column :courses, :published, :boolean, :default => false
  end

  def self.down
  end
end
