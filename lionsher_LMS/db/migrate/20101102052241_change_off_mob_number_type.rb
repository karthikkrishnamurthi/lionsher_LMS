class ChangeOffMobNumberType < ActiveRecord::Migration
  def self.up
    change_column :users, :off_number, :string
    change_column :users, :mob_number, :string
  end

  def self.down
  end
end
