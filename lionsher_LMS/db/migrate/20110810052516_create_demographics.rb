class CreateDemographics < ActiveRecord::Migration
  def self.up
    create_table :demographics do |t|
      t.string :demographic_type_1
      t.string :demographic_type_2
      t.string :demographic_type_3
      t.string :demographic_type_4
      t.text :demographic_option_1
      t.text :demographic_option_2
      t.text :demographic_option_3
      t.text :demographic_option_4
      t.integer :assessment_id

      t.timestamps
    end
  end

  def self.down
    drop_table :demographics
  end
end
