class ReportTemplate < ActiveRecord::Base
  attr_protected
  has_many	:report_components, :dependent => :destroy
  has_many	:reports, :dependent => :destroy
end
