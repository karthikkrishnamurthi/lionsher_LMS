class LearnerQuestion < ActiveRecord::Base
  attr_protected
  belongs_to  :learner
  belongs_to  :user
  belongs_to  :assessment
  belongs_to  :question_bank
  belongs_to  :question
  belongs_to  :tenant
end
