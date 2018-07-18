class ChangeQuarter < ActiveRecord::Migration
  current_time = Time.now
  current_month = current_time.month
  if current_month <= 3 then
    @quarter = "Q1"
  elsif current_month > 3 and current_month <= 6 then
    @quarter = "Q2"
  elsif current_month > 6 and current_month <= 9 then
    @quarter = "Q3"
  elsif current_month > 9 and current_month <= 12 then
    @quarter = "Q4"
  end
  def self.up
    change_column :tenants, :quarter, :string, :default => @quarter
  end

  def self.down
  end
end
