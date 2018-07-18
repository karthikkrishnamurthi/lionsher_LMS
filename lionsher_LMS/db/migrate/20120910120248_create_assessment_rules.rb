class CreateAssessmentRules < ActiveRecord::Migration
  def change
    create_table :assessment_rules do |t|
      t.integer :assessment_id
      t.integer :questions_required
      t.integer :questions_picked
      t.integer :tenant_id

      t.timestamps
    end
  end
end
