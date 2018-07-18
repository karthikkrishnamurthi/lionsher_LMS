class CreateInstructions < ActiveRecord::Migration
  def change
    create_table :instructions do |t|
      t.text :instruction_text
      t.integer :structure_component_id
      t.integer :tenant_id

      t.timestamps
    end
  end
end
