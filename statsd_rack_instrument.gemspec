# frozen-string-literal: true

Gem::Specification.new do |spec|
  spec.name = 'statsd-rack-instrument'
  spec.version = '0.0.1'
  spec.authors = ['michal-kazmierczak']
  spec.homepage = 'https://github.com/michal-kazmierczak/statsd-rack-instrument'
  spec.summary = 'StatsD instrumentation for Rack servers'
  spec.description = 'The statsd-rack-instrument gem enables a quick '\
                     'implementation of StatsD metrics. It adds metrics such '\
                     'as: rack_server_request_duration_seconds (histogram) '\
                     'and rack_server_exceptions_total (counter).'
  spec.license = 'MIT'

  spec.files = ['lib/statsd_rack_instrument.rb']
  spec.require_paths = ['lib']

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  spec.add_dependency 'statsd-instrument', '~> 3.1'
end
