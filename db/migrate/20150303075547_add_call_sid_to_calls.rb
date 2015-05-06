class AddCallSidToCalls < ActiveRecord::Migration
  def change
    add_column :calls, :call_id, :string
  end
end
