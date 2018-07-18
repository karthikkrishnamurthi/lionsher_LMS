class Section < ActiveRecord::Base
  attr_protected
  belongs_to  :structure_component
  belongs_to  :assessment
  has_many    :assessment_rules, :dependent => :destroy
end
