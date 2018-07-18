class CreateSubtopics < ActiveRecord::Migration
  def change
    create_table :subtopics do |t|
      t.string :name
      t.integer :topic_id
      t.integer :question_bank_id
      t.integer :tenant_id

      t.timestamps
    end
  end
end
