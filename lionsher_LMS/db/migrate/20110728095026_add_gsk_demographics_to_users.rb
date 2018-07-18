class AddGskDemographicsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users ,  :employee_number,  :text
    add_column :users ,  :team,  :string
    add_column :users ,  :headquarter,  :string
    add_column :users ,  :rbm_name,  :text
  end

  def self.down
  end
end
