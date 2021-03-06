class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts do |t|
      t.text :message
      t.integer :user_id
      t.integer :issue_id

      t.timestamps
    end
  end

  def self.down
    drop_table :posts
  end
end
