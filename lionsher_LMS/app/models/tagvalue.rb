class Tagvalue < ActiveRecord::Base
  attr_protected
  belongs_to	:tag
  has_many      :question_tags
  has_many      :questions, :through => :question_tags
  has_many		:rules
end
