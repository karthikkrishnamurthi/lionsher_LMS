class CreateProfileDropdownValues < ActiveRecord::Migration
  def change
    create_table :profile_dropdown_values do |t|
      t.integer :profile_id
      t.string :value

      t.timestamps
    end
  end
end
