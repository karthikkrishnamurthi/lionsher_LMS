class CreateTagvalues < ActiveRecord::Migration
  def self.up
    create_table :tagvalues do |t|
      t.string :value
      t.integer :tag_id
      t.integer :tagvalue_id

      t.timestamps
    end
  end

  def self.down
    drop_table :tagvalues
  end
end
