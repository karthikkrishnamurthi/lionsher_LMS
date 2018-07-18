class CreateTransactions < ActiveRecord::Migration
  def self.up
    create_table :transactions do |t|
      t.integer :response_code
      t.string :response_message
      t.string :date_created
      t.integer :payment_id
      t.integer :merchant_refno
      t.integer :amount
      t.string :mode
      t.string :description
      t.string :is_flagged
      t.integer :transaction_id
      t.integer :tenant_id

      t.timestamps
    end
  end

  def self.down
    drop_table :transactions
  end
end
