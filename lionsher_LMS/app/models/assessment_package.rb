class AssessmentPackage < ActiveRecord::Base
  attr_protected
  has_many :assessments
  has_many :coupons
end
