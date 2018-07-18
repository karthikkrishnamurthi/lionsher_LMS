class CreateCoupons < ActiveRecord::Migration
  def self.up
    create_table :coupons do |t|
      t.text :code
      t.integer :assessment_id

      t.timestamps
    end
  end

  def self.down
    drop_table :coupons
  end
end
