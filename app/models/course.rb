# Valiations and Associations
# Author : Karthik

class Course < ActiveRecord::Base
#  Two-to-three-upgrade-error
  attr_protected
  has_attached_file :image, :styles => {:thumb => "90x60#", :small => "120x90#", :medium => "200x150#" },
    :url => "/system/images/:id/:style/:basename.:extension",
    :path => ":rails_root/public/system/images/:id/:style/:basename.:extension"
  belongs_to :tenant
  belongs_to  :user
  belongs_to  :buyer
  belongs_to  :seller
  has_many :learners
  has_many  :assessment_courses
  has_many  :packages,  :through => :assessment_courses

  #stores details in learners table for every admin so that scorm courses
    #admin preview run like learners.
    #We got to pass current_user because there wont be any session during
    #delayed job worker process is running.
  def store_admin_details(course,current_user)
    learner = Learner.new
    learner.course_id = course.id
    learner.user_id = current_user.id
    learner.admin_id = current_user.id
    learner.tenant_id = current_user.tenant.id
    learner.group_id = current_user.group_id
    learner.type_of_test_taker = "admin"
    learner.save
    return learner
  end
  has_many  :coupons
end
