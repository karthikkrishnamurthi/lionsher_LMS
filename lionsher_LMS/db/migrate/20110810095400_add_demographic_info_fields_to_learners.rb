class AddDemographicInfoFieldsToLearners < ActiveRecord::Migration
  def self.up
    add_column :learners ,  :demographic_1,  :string
    add_column :learners ,  :demographic_2,  :string
    add_column :learners ,  :demographic_3,  :string
    add_column :learners ,  :demographic_4,  :string
  end

  def self.down
  end
end
