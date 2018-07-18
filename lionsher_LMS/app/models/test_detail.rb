class TestDetail < ActiveRecord::Base
  attr_protected
  belongs_to  :learner
  belongs_to  :question_bank
  belongs_to  :question
  belongs_to  :answer
  belongs_to  :user
  belongs_to  :tenant
  belongs_to  :assessment
end
