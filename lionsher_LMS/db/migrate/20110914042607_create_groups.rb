class CreateGroups < ActiveRecord::Migration
  def self.up
    create_table :groups do |t|
      t.string :group_name
      t.integer :user_id
      t.integer :tenant_id
      t.integer :no_of_learners

      t.timestamps
    end
  end

  def self.down
    drop_table :groups
  end
end
