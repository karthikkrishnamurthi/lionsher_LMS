class PricingPlan < ActiveRecord::Base
  attr_protected
  has_many  :tenants
  has_many 	:transactions
  has_many 	:transaction_logs
end
