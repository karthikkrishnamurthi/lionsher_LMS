class ChangeColumnInTransactions < ActiveRecord::Migration
  def up
    rename_column :transactions, :pricingplan_id, :pricing_plan_id
  end

  def down
  end
end
