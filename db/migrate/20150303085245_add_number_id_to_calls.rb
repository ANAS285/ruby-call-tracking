class AddNumberIdToCalls < ActiveRecord::Migration
  def change
    add_column :calls, :number_id, :integer
  end
end
