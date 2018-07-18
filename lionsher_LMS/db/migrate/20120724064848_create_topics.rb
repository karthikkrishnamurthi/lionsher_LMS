class CreateTopics < ActiveRecord::Migration
  def change
    create_table :topics do |t|
      t.string :name
      t.integer :question_bank_id
      t.integer :tenant_id

      t.timestamps
    end
  end
end
