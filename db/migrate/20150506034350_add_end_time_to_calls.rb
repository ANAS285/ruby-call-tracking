class AddEndTimeToCalls < ActiveRecord::Migration
  def change
    add_column :calls, :end_time, :datetime
  end
end
