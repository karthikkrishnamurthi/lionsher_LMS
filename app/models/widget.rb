class Widget < ActiveRecord::Base
  attr_protected
  belongs_to	:report_component
  has_one		:component_widget
end
