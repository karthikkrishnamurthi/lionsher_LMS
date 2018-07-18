class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.integer	:assessment_id
      t.integer	:report_template_id
      t.integer	:tenant_id
      t.integer	:structure_component_id
      t.timestamps
    end
  end
end
