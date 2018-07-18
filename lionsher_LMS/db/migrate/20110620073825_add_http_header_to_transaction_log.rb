class AddHttpHeaderToTransactionLog < ActiveRecord::Migration
  def self.up
    add_column :transaction_logs, :http_header, :text
  end

  def self.down
  end
end
