class QuestionBank < ActiveRecord::Base
  attr_protected
  belongs_to :user
  has_many   :questions
  has_many   :answers
  has_many   :assessments_question_banks
  has_many   :assessments, :through => :assessments_question_banks  

  # v2 related associations starts here
  belongs_to  :tenant
  has_many    :question_attributes
  has_many    :questions, :through => :question_attributes
  has_many    :topics, :through => :question_attributes
  has_many    :subtopics, :through => :question_attributes
  has_many    :errors, :through => :question_attributes
  has_many    :question_statuses, :through => :question_attributes
  has_many    :assessment_rules
  # v2 related associations ends here
end
