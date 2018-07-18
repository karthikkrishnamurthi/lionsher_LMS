class AddFolderToBlogs < ActiveRecord::Migration
  def self.up
    add_column :blogs, :folder, :string
  end

  def self.down
  end
end
