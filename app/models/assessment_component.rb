class AssessmentComponent < ActiveRecord::Base
  attr_protected
  has_one    :structure_component
  belongs_to :assessment
end
