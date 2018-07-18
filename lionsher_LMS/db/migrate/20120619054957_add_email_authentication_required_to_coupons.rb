class AddEmailAuthenticationRequiredToCoupons < ActiveRecord::Migration
  def change
    add_column  :coupons, :email_authentication_required, :boolean, :default => false
  end
end
