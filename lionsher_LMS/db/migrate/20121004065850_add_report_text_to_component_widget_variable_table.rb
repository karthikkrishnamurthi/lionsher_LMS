class AddReportTextToComponentWidgetVariableTable < ActiveRecord::Migration
  def change
  	add_column	:component_widget_variables, :report_text, :text
  end
end
