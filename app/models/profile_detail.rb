class ProfileDetail < ActiveRecord::Base
  attr_protected
  belongs_to  :profile
  belongs_to  :learner
end
