# Valiations and Associations
# Author : Karthik

class Blog < ActiveRecord::Base
  attr_protected
#  Two-to-three-upgrade-error
  has_attached_file :profile_photo, :styles => {:large => "298x238>",:medium => "87x68>"},
    :url => "/system/profile_photos/:id/:style/:basename.:extension",
    :path => ":rails_root/public/system/profile_photos/:id/:style/:basename.:extension"
end
