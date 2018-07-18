class AddPackageIdToCoupons < ActiveRecord::Migration
  def self.up
    add_column :coupons, :assessment_package_id, :integer
  end

  def self.down
  end
end
