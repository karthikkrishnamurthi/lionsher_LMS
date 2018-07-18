class AddAgeGenderQualificationToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :age, :integer, :default => 18
    add_column :users, :gender, :string, :default => "male"
    add_column :users, :qualification, :string
  end

  def self.down
  end
end
