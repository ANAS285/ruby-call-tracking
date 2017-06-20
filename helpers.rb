def get_from_cache(env, key, action)
  cache = env["rack.moneta_store"]
  item = cache[key]
  return item if item
  item = action.call()
  cache[key] = item
  item
end
