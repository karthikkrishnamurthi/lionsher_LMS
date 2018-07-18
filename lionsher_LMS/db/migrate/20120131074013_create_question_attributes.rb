class CreateQuestionAttributes < ActiveRecord::Migration
  def self.up
    create_table :question_attributes do |t|
      t.integer :question_id
      t.integer :tag_id
      t.integer :tenant_id

      t.timestamps
    end
  end

  def self.down
    drop_table :question_attributes
  end
end
