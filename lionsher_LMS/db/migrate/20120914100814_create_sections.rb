class CreateSections < ActiveRecord::Migration
  def change
    create_table :sections do |t|
      t.string :name
      t.integer :structure_component_id
      t.integer :tenant_id

      t.timestamps
    end
  end
end
