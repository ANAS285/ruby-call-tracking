class AddBwIdToNumbers < ActiveRecord::Migration
  def change
    add_column :numbers, :bw_id, :string
  end
end
