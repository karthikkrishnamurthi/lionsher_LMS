class ChangePricingPlanDefaults < ActiveRecord::Migration
  def self.up
    change_column :pricing_plans, :allow_scorm, :boolean, :default => true
    change_column :pricing_plans, :allow_nonscorm,:boolean, :default => true
    change_column :pricing_plans, :allow_ppt,:boolean, :default => true
    change_column :pricing_plans, :allow_flash,:boolean, :default => true
    change_column :pricing_plans, :allow_pdf,:boolean, :default => true
    change_column :pricing_plans, :allow_audio,:boolean, :default => true
    change_column :pricing_plans, :allow_video,:boolean, :default => true
    change_column :pricing_plans, :allow_assessments,:boolean, :default => true
  end

  def self.down
  end
end
