class AddNoOfRatingsAndNoOfRatingRecordsToCourse < ActiveRecord::Migration
  def self.up
    add_column :courses, :total_no_of_ratings, :integer, :default => 0
    add_column :courses, :no_of_rating_records, :integer, :default => 0
  end

  def self.down
  end
end
