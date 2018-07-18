class CreateComponentWidgets < ActiveRecord::Migration
  def change
    create_table :component_widgets do |t|
      t.integer :report_component_id
      t.integer :widget_id

      t.timestamps
    end
  end
end
