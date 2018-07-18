class AddIsSavedToStructureComponents < ActiveRecord::Migration
  def change
    add_column :structure_components , :is_saved ,:string, :default => "false"
  end
end
