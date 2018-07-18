class Answer < ActiveRecord::Base
  attr_protected
  belongs_to :question
  belongs_to :question_bank
  has_attached_file :answer_image, :styles => {:small => "300x300>"},
    :url => "/system/answer_images/:id/:style/:basename.:extension",
    :path => ":rails_root/public/system/answer_images/:id/:style/:basename.:extension"
end
