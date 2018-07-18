class AddHourMinToSections < ActiveRecord::Migration
  def change
    add_column :sections, :duration_hour, :integer, :default => 0
    add_column :sections, :duration_min, :integer, :default => 30
  end
end
