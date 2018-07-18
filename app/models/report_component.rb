class ReportComponent < ActiveRecord::Base
  attr_protected
  belongs_to	:report_template
  has_many		:component_widgets, :dependent => :destroy
  has_many		:widgets, :through => :component_widgets
end
