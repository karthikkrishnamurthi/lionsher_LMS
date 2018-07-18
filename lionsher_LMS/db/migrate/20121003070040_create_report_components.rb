class CreateReportComponents < ActiveRecord::Migration
  def change
    create_table :report_components do |t|
      t.string :component_name
      t.integer :report_template_id

      t.timestamps
    end
  end
end
