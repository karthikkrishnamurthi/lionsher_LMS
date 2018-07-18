class AddForWhomColumToReportTable < ActiveRecord::Migration
  def change
  	add_column	:reports, :for_whom, :string
  end
end
