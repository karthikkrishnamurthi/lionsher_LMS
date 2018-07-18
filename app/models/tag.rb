class Tag < ActiveRecord::Base
  attr_protected
  has_many   	:tagvalues
  belongs_to    :tenant
  has_many		:rules
end
