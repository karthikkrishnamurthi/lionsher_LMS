class AddAssmtOrderLocationToPackages < ActiveRecord::Migration
  def self.up
    add_column  :assessment_packages, :assessment_order,  :text
  end

  def self.down
  end
end
