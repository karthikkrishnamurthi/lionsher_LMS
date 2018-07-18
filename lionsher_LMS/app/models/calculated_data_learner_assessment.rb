class CalculatedDataLearnerAssessment < ActiveRecord::Base
  attr_protected
  belongs_to	:learner
  belongs_to	:user
  belongs_to	:tenant
  belongs_to	:assessment  
end
