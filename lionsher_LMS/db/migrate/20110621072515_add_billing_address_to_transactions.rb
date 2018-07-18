class AddBillingAddressToTransactions < ActiveRecord::Migration
  def self.up
    add_column :transactions, :billing_address, :string
    add_column :transactions, :billing_city, :string
    add_column :transactions, :billing_state, :string
    add_column :transactions, :billing_postal_code, :string
    add_column :transactions, :billing_country, :string
    add_column :transactions, :billing_phone, :string

    add_column :transactions, :delivery_address, :string
    add_column :transactions, :delivery_city, :string
    add_column :transactions, :delivery_state, :string
    add_column :transactions, :delivery_postal_code, :string
    add_column :transactions, :delivery_country, :string
    add_column :transactions, :delivery_phone, :string

  end

  def self.down
  end
end
