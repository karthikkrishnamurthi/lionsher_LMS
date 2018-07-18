class CreateStructureComponents < ActiveRecord::Migration
  def change
    create_table :structure_components do |t|
      t.integer :assessment_id
      t.integer :assessment_component_id
      t.integer :tenant_id

      t.timestamps
    end
  end
end
