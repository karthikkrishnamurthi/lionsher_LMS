class Instruction < ActiveRecord::Base
  attr_protected
  belongs_to  :structure_component
end
