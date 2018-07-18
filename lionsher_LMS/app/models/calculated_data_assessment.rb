class CalculatedDataAssessment < ActiveRecord::Base
  attr_protected
  belongs_to	:assessment
  belongs_to	:tenant
end
