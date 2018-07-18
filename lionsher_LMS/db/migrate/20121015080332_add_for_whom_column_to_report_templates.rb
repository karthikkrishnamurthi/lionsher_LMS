class AddForWhomColumnToReportTemplates < ActiveRecord::Migration
  def change
  	add_column	:report_templates, :for_whom, :string
  end
end
