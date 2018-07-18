class TestPattern < ActiveRecord::Base
  attr_protected
  has_many :assessments
end
