class Subtopic < ActiveRecord::Base
  attr_protected
  belongs_to :tenant
  has_many  :question_attributes
  has_many  :questions, :through => :question_attributes
  has_many  :question_banks, :through => :question_attributes
  has_many  :topics, :through => :question_attributes
  has_many  :errors, :through => :question_attributes
  has_many  :difficulties, :through => :question_attributes
  has_many  :passages, :through => :question_attributes
  has_many  :directions, :through => :question_attributes
  has_many  :question_types, :through => :question_attributes
  has_many  :question_statuses, :through => :question_attributes
end
