def get_value(dimension, name)
  dimension.find{|d| d[:name] == name}[:value]
end
