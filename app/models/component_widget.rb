class ComponentWidget < ActiveRecord::Base
  attr_protected
  belongs_to	:report_component
  belongs_to	:widget
  has_many		:component_widget_variables, :dependent => :destroy
  has_many		:report_variables, :through => :component_widget_variables
end
