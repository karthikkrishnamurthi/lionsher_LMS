class ComponentWidgetVariable < ActiveRecord::Base
  attr_protected
  belongs_to	:component_widget
  belongs_to	:report_variable
  belongs_to	:report_component
  belongs_to	:widget
end
