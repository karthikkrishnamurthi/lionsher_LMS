class RenameImportColumnToExcelFromCsv < ActiveRecord::Migration
  def up
    rename_column :imports, :csv_file_name, :excel_file_name
    rename_column :imports, :csv_content_type, :excel_content_type
    rename_column :imports, :csv_file_size, :excel_file_size
  end

  def down
  end
end
