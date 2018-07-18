class CreateRules < ActiveRecord::Migration
  def change
    create_table :rules do |t|
      t.integer :assessment_rule_id
      t.integer :tag_id
      t.integer :tagvalue_id
      t.integer :tenant_id
      t.timestamps
    end
  end
end