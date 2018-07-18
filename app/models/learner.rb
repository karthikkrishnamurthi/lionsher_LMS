# Valiations and Associations
# Author : Karthik

class Learner < ActiveRecord::Base
  attr_protected
  belongs_to  :user
  belongs_to  :tenant
  belongs_to  :assessment
  belongs_to  :course
  belongs_to  :group
  has_many    :descriptive_answers
  has_many    :test_details, :dependent => :destroy
  has_many    :questions, :through => :test_details
  has_many    :question_banks, :through => :test_details
  belongs_to  :package
  has_many    :calculated_data_learner_assessments
  has_many    :profile_details
end
