class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.string :field_name
      t.string :field_type
      t.integer :structure_component_id
      t.integer :tenant_id

      t.timestamps
    end
  end
end
