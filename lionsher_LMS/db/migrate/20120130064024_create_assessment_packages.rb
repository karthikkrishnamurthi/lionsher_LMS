class CreateAssessmentPackages < ActiveRecord::Migration
  def self.up
    create_table :assessment_packages do |t|
      t.string :name
      t.integer :tenant_id
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :assessment_packages
  end
end
