class CreateErrors < ActiveRecord::Migration
  def change
    create_table :errors do |t|
      t.text :error_text
      t.integer :tenant_id

      t.timestamps
    end
  end
end
