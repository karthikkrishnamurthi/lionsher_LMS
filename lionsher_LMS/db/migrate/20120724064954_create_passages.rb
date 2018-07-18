class CreatePassages < ActiveRecord::Migration
  def change
    create_table :passages do |t|
      t.text :passage_text
      t.integer :question_bank_id
      t.integer :tenant_id

      t.timestamps
    end
  end
end
