class AddMaxLearnerCreditToTenants < ActiveRecord::Migration
  def self.up
    add_column :tenants , :max_learner_credit, :integer
  end

  def self.down
  end
end
