class Import < ActiveRecord::Base
  attr_protected
  attr_accessor :excel_file_name, :excel_content_type, :excel_file_size
  has_attached_file :excel
  validates_attachment_presence :excel
  validates_attachment_content_type :excel, :content_type => ['text/csv','text/comma-separated-values','text/csv','application/csv','application/excel','application/vnd.ms-excel','application/vnd.msexcel','text/anytext','text/plain', 'application/vnd.oasis.opendocument.spreadsheet','application/vnd.openxmlformats-officedocument.spreadsheetml.sheet']
end
