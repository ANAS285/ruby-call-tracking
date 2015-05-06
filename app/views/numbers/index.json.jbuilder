json.array!(@numbers) do |number|
  json.extract! number, :id, :area_code, :tracking_number, :business_number
  json.url number_url(number, format: :json)
end
