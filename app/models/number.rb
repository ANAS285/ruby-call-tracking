class Number < ActiveRecord::Base

validates :area_code, :presence => true
validates :business_number, :presence => true

end
