class RemoveUnnecessaryColumnsFromAssessmentsAndUsers < ActiveRecord::Migration
  def self.up
    remove_column :assessments, :show_score
    remove_column :assessments, :show_score_after_test
    remove_column :assessments, :take_name
    remove_column :assessments, :take_age
    remove_column :assessments, :take_gender
    remove_column :assessments, :take_qualification
    remove_column :assessments, :take_demographic_information
    remove_column :assessments, :cummulative_time

    remove_column :users, :age
    remove_column :users, :gender
    remove_column :users, :qualification
    remove_column :users, :company_name
    remove_column :users, :company_url
    remove_column :users, :about_company
    remove_column :users, :employee_number
    remove_column :users, :team
    remove_column :users, :headquarter
    remove_column :users, :rbm_name
  end

  def self.down
  end
end
