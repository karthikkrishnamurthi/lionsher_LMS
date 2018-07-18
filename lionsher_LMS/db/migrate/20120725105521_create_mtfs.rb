class CreateMtfs < ActiveRecord::Migration
  def change
    create_table :mtfs do |t|
      t.integer :question_id
      t.string :match_item
      t.string :match_option
      t.integer :mtf_id
      t.integer :tenant_id
      t.timestamps
    end
  end
end
