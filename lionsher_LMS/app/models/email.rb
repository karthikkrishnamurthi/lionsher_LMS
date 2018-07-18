class Email < ActiveRecord::Base
  attr_protected
  belongs_to  :user
  belongs_to  :tenant
end
