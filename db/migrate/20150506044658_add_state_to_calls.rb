class AddStateToCalls < ActiveRecord::Migration
  def change
    add_column :calls, :state, :string
  end
end
