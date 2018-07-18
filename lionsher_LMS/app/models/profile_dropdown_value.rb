class ProfileDropdownValue < ActiveRecord::Base
  attr_protected
  belongs_to  :profile
end
