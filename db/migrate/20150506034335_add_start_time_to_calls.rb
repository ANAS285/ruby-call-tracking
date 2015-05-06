class AddStartTimeToCalls < ActiveRecord::Migration
  def change
    add_column :calls, :start_time, :datetime
  end
end
