class StructureComponent < ActiveRecord::Base
  attr_protected
  belongs_to  :tenant
  belongs_to  :assessment_component
  belongs_to  :assessment
  has_one     :section, :dependent => :destroy
  has_many    :profiles, :dependent => :destroy
  has_one     :instruction, :dependent => :destroy
  has_one	  :report, :dependent => :destroy
end
