class CreateComponentWidgetVariables < ActiveRecord::Migration
  def change
    create_table :component_widget_variables do |t|
      t.integer :component_widget_id
      t.integer :report_variable_id

      t.timestamps
    end
  end
end
