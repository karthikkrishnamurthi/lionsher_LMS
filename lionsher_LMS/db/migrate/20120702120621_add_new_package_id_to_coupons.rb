class AddNewPackageIdToCoupons < ActiveRecord::Migration
  def change
    add_column :coupons, :package_id, :integer
  end
end
