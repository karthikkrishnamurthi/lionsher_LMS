class QuestionTag < ActiveRecord::Base
  attr_protected
  belongs_to	:tagvalue
  belongs_to	:question
end
