# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "fluent-plugin-pgjson"
  s.version     = "0.0.8"
  s.authors     = ["OKUNO Akihiro"]
  s.email       = ["choplin.choplin@gmail.com"]
  s.homepage    = "https://github.com/choplin/fluent-plugin-pgjson"
  s.summary     = %q{}
  s.description = %q{}
  s.license  = "Apache-2.0"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "fluentd"
  s.add_runtime_dependency "pg"
end
