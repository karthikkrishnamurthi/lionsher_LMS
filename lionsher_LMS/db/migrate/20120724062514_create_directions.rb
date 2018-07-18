class CreateDirections < ActiveRecord::Migration
  def change
    create_table :directions do |t|
      t.text :direction_text
      t.integer :question_bank_id
      t.integer :tenant_id

      t.timestamps
    end
  end
end
