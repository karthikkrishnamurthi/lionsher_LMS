class AddTimeBoundToSections < ActiveRecord::Migration
  def change
    add_column :sections, :time_bound, :string
  end
end
