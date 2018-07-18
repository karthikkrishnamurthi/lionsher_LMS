class Question < ActiveRecord::Base
  attr_protected

  has_attached_file :question_image, :styles => {:small => "500x500>"},
    :url => "/system/question_images/:id/:style/:basename.:extension",
    :path => ":rails_root/public/system/question_images/:id/:style/:basename.:extension"
  belongs_to :question_bank
  has_many   :descriptive_answers
  has_many   :assessment_questions
  has_many   :assessments, :through => :assessments_questions

  # v2 related associations strats here
  belongs_to  :tenant
  has_many  :answers
  has_many  :question_attributes
  has_many  :question_banks, :through => :question_attributes
  has_many  :question_types, :through => :question_attributes
  has_many  :question_statuses, :through => :question_attributes
  has_many  :passages, :through => :question_attributes
  has_many  :directions, :through => :question_attributes
  has_many  :topics, :through => :question_attributes
  has_many  :subtopics, :through => :question_attributes
  has_many  :difficulties, :through => :question_attributes
  has_many  :user_tests,  :through => :test_details

  has_many      :question_tags
  has_many      :tagvalues, :through => :question_tags

  has_one   :image
  # v2 related associations ends here
end
