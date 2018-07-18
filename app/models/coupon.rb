class Coupon < ActiveRecord::Base
  attr_protected
  belongs_to :assessment_package
  belongs_to :assessment
  belongs_to :course
  belongs_to :package
end
