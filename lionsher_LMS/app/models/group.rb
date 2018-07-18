class Group < ActiveRecord::Base
  attr_protected
  has_many :users
  belongs_to :tenant
  belongs_to :user
  has_many  :learners
end
