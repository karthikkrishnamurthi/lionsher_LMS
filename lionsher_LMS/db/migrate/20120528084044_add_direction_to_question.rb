class AddDirectionToQuestion < ActiveRecord::Migration
  def change
    add_column  :questions, :direction_text, :text, :dafault => ""
  end
end
