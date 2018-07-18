class AddDivNameColumnToWidgets < ActiveRecord::Migration
  def change
    add_column  :widgets, :div_name, :string
  end
end
