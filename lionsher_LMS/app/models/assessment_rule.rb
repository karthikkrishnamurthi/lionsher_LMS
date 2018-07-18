class AssessmentRule < ActiveRecord::Base
	attr_protected
	belongs_to  :assessment
	has_many  	:rules, :dependent => :destroy
	belongs_to	:question_bank
	belongs_to	:question_type
	belongs_to	:difficulty
  belongs_to	:section
end
