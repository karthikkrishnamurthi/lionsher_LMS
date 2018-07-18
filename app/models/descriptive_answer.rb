class DescriptiveAnswer < ActiveRecord::Base
  attr_protected
  belongs_to :user
  belongs_to :assessment
  belongs_to :question
  belongs_to :learner
end
