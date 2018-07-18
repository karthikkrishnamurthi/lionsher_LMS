# Valiations and Associations
# Author : Karthik

class Tenant < ActiveRecord::Base
  attr_protected
#  Two-to-three-upgrade-error  
  has_attached_file :logo, :styles => {:small => "120x90>"},
    :url => "/system/logos/:id/:style/:basename.:extension",
    :path => ":rails_root/public/system/logos/:id/:style/:basename.:extension"
  has_many :users
  belongs_to :user
  has_many :assessments
  has_many :question_banks
  has_many :courses
  has_many :learners
  belongs_to :pricing_plan
  has_many  :groups
  has_many   :question_attributes
  has_many   :questions, :through => :question_attributes
  has_many   :tags, :through => :question_attributes
  has_many   :tagvalues, :through => :question_attributes
  has_many  :emails
  has_many  :transactions
  has_many  :calculated_data_learner_assessments
  has_many  :reports
  validates_presence_of     :organization, :logo
  validates_length_of       :organization, :within => 1..100
end