json.array!(@calls) do |call|
  json.extract! call, :id, :call_duration, :from, :to
  json.url call_url(call, format: :json)
end
