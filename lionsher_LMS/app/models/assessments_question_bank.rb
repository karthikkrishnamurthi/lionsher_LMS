class AssessmentsQuestionBank < ActiveRecord::Base
  attr_protected
  belongs_to :assessment
  belongs_to :question_bank
end
