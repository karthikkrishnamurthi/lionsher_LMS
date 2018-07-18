class AddPaymentDoneToTransactions < ActiveRecord::Migration
  def self.up
    add_column :transactions, :payment_done, :integer
  end

  def self.down
  end
end
