class QuestionType < ActiveRecord::Base
  attr_protected
  has_many  :assessment_rules
end
