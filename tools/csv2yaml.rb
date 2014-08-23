require 'csv'
require 'yaml'

def get_statistics(type)
  case type
  when "AVG"
    ["Maximum", "Minimum", "Average"]
  when "SUM"
    ["Sum"]
  end
end

yaml = []

CSV.foreach('template.csv'){|row|
  yaml << {"namespace" => row[0], "metric_name" => row[1], "statistics" => get_statistics(row[2])}
}

print YAML.dump(yaml)
