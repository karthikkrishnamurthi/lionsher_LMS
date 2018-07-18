class AddAssociationsToTables < ActiveRecord::Migration
  def self.up
    add_column :assessments, :tenant_id, :integer
    add_column :users, :tenant_id, :integer
    add_column :courses, :tenant_id, :integer
    rename_column :answers, :qid, :question_id
    rename_column :questions, :qb_id, :question_bank_id
  end

  def self.down
  end
end
