class Topic < ActiveRecord::Base
  attr_protected
  belongs_to :tenant
  has_many  :question_attributes
  has_many  :questions, :through => :question_attributes
  has_many  :question_banks, :through => :question_attributes
  has_many  :subtopics, :through => :question_attributes
  has_many  :errors, :through => :question_attributes
  has_many  :question_statuses, :through => :question_attributes
end
