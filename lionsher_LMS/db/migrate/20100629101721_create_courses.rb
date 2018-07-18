class CreateCourses < ActiveRecord::Migration
  def self.up
    create_table :courses do |t|
      t.string :course_name
      t.text :description
      t.float :duration
      t.string :image_file_name
      t.string :image_content_type
      t.integer :image_file_size
      t.string :path
      t.string :url
      t.string :typeofcourse
      t.integer :size, :default => 0
      t.string  :feedback, :default => "checked"
      t.integer :user_id
      t.timestamps
    end
  end

  def self.down
    drop_table :courses
  end
end
