class AddCouponStatusToCoupons < ActiveRecord::Migration
  def self.up
    add_column :coupons, :status, :string
  end

  def self.down
  end
end
