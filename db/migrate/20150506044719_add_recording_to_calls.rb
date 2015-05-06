class AddRecordingToCalls < ActiveRecord::Migration
  def change
    add_column :calls, :recording_url, :string
  end
end
