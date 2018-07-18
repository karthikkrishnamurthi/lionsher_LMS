class Post < ActiveRecord::Base
  attr_protected
  has_many :users
end
