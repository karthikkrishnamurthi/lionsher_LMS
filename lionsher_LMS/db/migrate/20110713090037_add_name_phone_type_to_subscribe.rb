class AddNamePhoneTypeToSubscribe < ActiveRecord::Migration
  def self.up
    add_column :subscribes, :name, :string
    add_column :subscribes, :phone_number, :string
    add_column :subscribes, :type_of_user, :string
    add_column :subscribes, :course_id, :integer
  end

  def self.down
  end
end
