class CreateNumbers < ActiveRecord::Migration
  def change
    create_table :numbers do |t|
      t.string :area_code
      t.string :tracking_number
      t.string :business_number

      t.timestamps
    end
  end
end
