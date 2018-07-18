class Transaction < ActiveRecord::Base
  attr_protected
  belongs_to :tenant
  belongs_to :pricing_plan
end
