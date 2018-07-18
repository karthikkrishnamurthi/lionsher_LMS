class Package < ActiveRecord::Base
  attr_protected
  has_many  :assessment_courses , :dependent => :destroy
  has_many  :assessments, :through => :assessment_courses
  has_many  :courses, :through => :assessment_courses
  belongs_to  :tenant
  belongs_to  :user
  has_many  :coupons, :dependent => :destroy
  has_many  :learners
#  accepts_nested_attributes_for :assessment_courses, :allow_destroy => true
  has_attached_file :package_image, :styles => {:small => "120x90#"},
    :url => "/system/package_image/:id/:style/:basename.:extension",
    :path => ":rails_root/public/system/package_image/:id/:style/:basename.:extension"
end
