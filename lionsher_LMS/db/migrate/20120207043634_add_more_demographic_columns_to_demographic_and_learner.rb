class AddMoreDemographicColumnsToDemographicAndLearner < ActiveRecord::Migration
  def self.up
    add_column  :demographics, :demographic_type_5, :string
    add_column  :demographics, :demographic_type_6, :string
    add_column  :demographics, :demographic_type_7, :string
    add_column  :demographics, :demographic_type_8, :string
    add_column  :demographics, :demographic_type_9, :string
    add_column  :demographics, :demographic_type_10, :string
    add_column  :demographics, :demographic_type_11, :string
    add_column  :demographics, :demographic_type_12, :string
    add_column  :demographics, :demographic_type_13, :string
    add_column  :demographics, :demographic_type_14, :string
    add_column  :demographics, :demographic_type_15, :string

    add_column  :demographics, :demographic_option_5, :text
    add_column  :demographics, :demographic_option_6, :text
    add_column  :demographics, :demographic_option_7, :text
    add_column  :demographics, :demographic_option_8, :text
    add_column  :demographics, :demographic_option_9, :text
    add_column  :demographics, :demographic_option_10, :text
    add_column  :demographics, :demographic_option_11, :text
    add_column  :demographics, :demographic_option_12, :text
    add_column  :demographics, :demographic_option_13, :text
    add_column  :demographics, :demographic_option_14, :text
    add_column  :demographics, :demographic_option_15, :text

    add_column  :learners, :demographic_5, :string
    add_column  :learners, :demographic_6, :string
    add_column  :learners, :demographic_7, :string
    add_column  :learners, :demographic_8, :string
    add_column  :learners, :demographic_9, :string
    add_column  :learners, :demographic_10, :string
    add_column  :learners, :demographic_11, :string
    add_column  :learners, :demographic_12, :string
    add_column  :learners, :demographic_13, :string
    add_column  :learners, :demographic_14, :string
    add_column  :learners, :demographic_15, :string
  end

  def self.down
  end
end
