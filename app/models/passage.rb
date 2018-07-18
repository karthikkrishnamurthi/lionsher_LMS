class Passage < ActiveRecord::Base
  attr_protected
  has_many  :question_attributes
  has_many  :questions, :through => :question_attributes
  has_many  :subtopics, :through => :question_attributes
end
