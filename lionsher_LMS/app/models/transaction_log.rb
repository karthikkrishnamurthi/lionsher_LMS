class TransactionLog < ActiveRecord::Base
  attr_protected
  belongs_to  :pricing_plan
end
