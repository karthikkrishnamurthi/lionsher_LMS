class AssessmentCourse < ActiveRecord::Base
  attr_protected
  belongs_to :package
  belongs_to :user
  belongs_to :tenant
  belongs_to :assessment_package
  belongs_to :assessment
  belongs_to :course
end
