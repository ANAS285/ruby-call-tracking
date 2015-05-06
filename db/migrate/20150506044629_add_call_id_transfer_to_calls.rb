class AddCallIdTransferToCalls < ActiveRecord::Migration
  def change
    add_column :calls, :call_id_transfer, :string
  end
end
