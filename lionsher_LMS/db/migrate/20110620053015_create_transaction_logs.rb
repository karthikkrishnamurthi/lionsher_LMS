class CreateTransactionLogs < ActiveRecord::Migration
  def self.up
    create_table :transaction_logs do |t|
      t.integer :transaction_id
      t.integer :reference_no
      t.string :transaction_status
      t.integer :pricingplan_id
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :transaction_logs
  end
end
