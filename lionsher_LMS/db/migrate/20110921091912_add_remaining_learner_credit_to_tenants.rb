class AddRemainingLearnerCreditToTenants < ActiveRecord::Migration
  def self.up
    add_column :tenants , :remaining_learner_credit, :integer
  end

  def self.down
  end
end
