all_files = `git ls-files -z`.split("\x0")

Gem::Specification.new do |s|
  s.name = 'aws-reporting'
  s.version = '0.9.2'
  s.date = '2014-08-21'
  s.summary = "AWS performance reporting tool"
  s.description = "AWS performance reporting tool"
  s.authors = ["xmisao"]
  s.email = 'mail@xmisao.com'
  s.files = all_files.grep(%r{^(bin|lib|metrics|template)/})
  s.homepage = 'https://github.com/xmisao/aws-reporting'
  s.license = 'MIT'
  s.executables = all_files.grep(%r{^bin/}){|f| File.basename(f)}

  s.add_runtime_dependency('slop', "~> 3.5.0")
  s.add_runtime_dependency('aws-sdk', "~> 1.49.0")
  s.add_runtime_dependency('formatador', "~> 0.2.4")
  s.add_runtime_dependency('parallel', "~> 1.2.2")
end

