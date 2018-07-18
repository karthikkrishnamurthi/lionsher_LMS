class ChangeColumnInTransactionLog < ActiveRecord::Migration
  def up
  	rename_column :transaction_logs, :pricingplan_id, :pricing_plan_id
  end
end
