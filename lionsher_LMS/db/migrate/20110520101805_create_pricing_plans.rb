class CreatePricingPlans < ActiveRecord::Migration
  def self.up
    create_table :pricing_plans do |t|
      t.string :plan_name
      t.integer :amount
      t.integer :no_of_users
      t.integer :space_in_gb
      t.boolean :allow_scorm
      t.boolean :allow_nonscorm
      t.boolean :allow_ppt
      t.boolean :allow_flash
      t.boolean :allow_pdf
      t.boolean :allow_audio
      t.boolean :allow_video
      t.boolean :allow_assessments
      t.datetime :plan_expiry

      t.timestamps
    end
  end

  def self.down
    drop_table :pricing_plans
  end
end
