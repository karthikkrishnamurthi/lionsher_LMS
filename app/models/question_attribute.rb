class QuestionAttribute < ActiveRecord::Base
  attr_protected
  belongs_to   :tenant
  belongs_to   :question_bank
  belongs_to   :question
  belongs_to   :tag
  belongs_to   :tag_value
  belongs_to   :passage
  belongs_to   :direction
  belongs_to   :question_type
  belongs_to   :question_status
  belongs_to   :topic
  belongs_to   :subtopic
  belongs_to   :difficulty
  belongs_to   :error
  validates :question_id, :uniqueness => :true
end
