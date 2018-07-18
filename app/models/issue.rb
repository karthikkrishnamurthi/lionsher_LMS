class Issue < ActiveRecord::Base
  attr_protected
  has_attached_file :image, :styles => { :medium => "600x600>" }
  belongs_to  :user
  belongs_to  :post
end
