class AddFwdToToCalls < ActiveRecord::Migration
  def change
    add_column :calls, :fwd_to, :string
  end
end
