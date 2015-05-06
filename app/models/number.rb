class Number < ActiveRecord::Base

validates :area_code, :presence => true
validates :business_number, :presence => true
validates :tracking_number, :presence => { message: "No tracking numbers available for that area code. Try a new area code." }

end
