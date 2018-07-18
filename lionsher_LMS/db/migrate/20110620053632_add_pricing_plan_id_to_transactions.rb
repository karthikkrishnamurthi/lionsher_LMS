class AddPricingPlanIdToTransactions < ActiveRecord::Migration
  def self.up
    add_column :transactions, :pricingplan_id, :integer
  end

  def self.down
  end
end
