class CreateCalls < ActiveRecord::Migration
  def change
    create_table :calls do |t|
      t.string :call_duration
      t.string :from
      t.string :to

      t.timestamps
    end
  end
end
