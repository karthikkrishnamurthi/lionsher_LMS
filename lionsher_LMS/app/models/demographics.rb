class Demographics < ActiveRecord::Base
  attr_protected
  belongs_to :assessment
end
