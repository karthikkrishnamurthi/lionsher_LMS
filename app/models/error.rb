class Error < ActiveRecord::Base
  attr_protected
  has_many  :question_attributes
  has_many  :question_banks, :through => :question_attributes
  has_many  :topics, :through => :question_attributes
  has_many  :subtopics, :through => :question_attributes
end
