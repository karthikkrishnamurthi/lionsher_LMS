class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.string :image_file_name
      t.string :image_content_type
      t.integer :image_file_size
      t.string :image_path
      t.integer :question_id
      t.integer :answer_id
      t.integer :tenant_id

      t.timestamps
    end
  end
end
