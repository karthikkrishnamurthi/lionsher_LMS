class AssessmentQuestion < ActiveRecord::Base
  attr_protected
  belongs_to :assessment
  belongs_to :question
end
