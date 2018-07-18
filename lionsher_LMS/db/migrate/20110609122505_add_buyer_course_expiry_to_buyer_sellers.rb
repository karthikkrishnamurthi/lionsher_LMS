class AddBuyerCourseExpiryToBuyerSellers < ActiveRecord::Migration
  def self.up
     add_column :buyer_sellers, :buyer_course_expiry, :datetime
  end

  def self.down
  end
end
