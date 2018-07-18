class CreateReportVariables < ActiveRecord::Migration
  def change
    create_table :report_variables do |t|
      t.string :name
      t.string :method_name
      
      t.timestamps
    end
  end
end
