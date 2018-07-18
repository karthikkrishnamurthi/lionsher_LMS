class CreateBlogs < ActiveRecord::Migration
  def self.up
    create_table :blogs do |t|
      t.string :blog_name
      t.string :blog_title
      t.string :blog_type
      t.text :blog_content
      t.string :profile_photo_file_name
      t.string :profile_photo_content_type
      t.integer :profile_photo_file_size
      t.datetime :profile_photo_updated_at
      t.text :rss_content
      t.timestamps
    end
  end

  def self.down
    drop_table :blogs
  end
end
