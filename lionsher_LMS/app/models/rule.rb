class Rule < ActiveRecord::Base
  attr_protected
  belongs_to  :assessment_rule
  belongs_to	:tag
  belongs_to	:tagvalue
end
