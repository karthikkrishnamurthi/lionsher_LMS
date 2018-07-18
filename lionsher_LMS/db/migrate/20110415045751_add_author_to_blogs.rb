class AddAuthorToBlogs < ActiveRecord::Migration
  def self.up
    add_column  :blogs, :author, :string
  end

  def self.down
  end
end
