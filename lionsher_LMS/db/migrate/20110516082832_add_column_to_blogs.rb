class AddColumnToBlogs < ActiveRecord::Migration
  def self.up
    add_column :blogs , :designation ,:string
    add_column :blogs , :linkedin ,:string
    add_column :blogs , :twitter ,:string
    add_column :blogs , :blog ,:string
    add_column :blogs , :facebook ,:string
    add_column :blogs , :orkut ,:string
    add_column :blogs , :website ,:string
    add_column :blogs , :lionsher_url ,:string
    end

  def self.down
  end
end
