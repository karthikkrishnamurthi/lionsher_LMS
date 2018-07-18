class CreatePulseSurveys < ActiveRecord::Migration
  def self.up
    create_table :pulse_surveys do |t|
      t.string :name
      t.text :email
      t.text :coupon_code

      t.timestamps
    end
  end

  def self.down
    drop_table :pulse_surveys
  end
end
