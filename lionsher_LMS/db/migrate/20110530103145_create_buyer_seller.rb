class CreateBuyerSeller < ActiveRecord::Migration
  def self.up
    create_table :buyer_sellers do |t|
      t.integer :seller_user_id
      t.integer :course_id
      t.integer :buyer_user_id
      t.integer :no_of_license
      t.integer :price
      t.timestamps
    end
  end

  def self.down
  end
end
