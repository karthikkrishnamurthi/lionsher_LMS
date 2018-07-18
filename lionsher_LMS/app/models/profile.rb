class Profile < ActiveRecord::Base
  attr_protected
  belongs_to  :structure_component
  has_one     :profile_detail, :dependent => :destroy
  has_many    :profile_dropdown_values, :dependent => :destroy
end
