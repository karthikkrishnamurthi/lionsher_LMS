class AddCoursePaymentDoneToBuyerSellers < ActiveRecord::Migration
  def self.up
   add_column :buyer_sellers, :course_payment_done, :boolean, :default => false
  end

  def self.down
  end
end
