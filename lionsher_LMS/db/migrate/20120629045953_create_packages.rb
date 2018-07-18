class CreatePackages < ActiveRecord::Migration
  def change
    create_table :packages do |t|
      t.string :name
      t.text :description
      t.text :instructions
      t.integer :user_id
      t.integer :tenant_id

      t.timestamps
    end
  end
end
