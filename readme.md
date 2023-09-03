# statsd-rack-instrument

A Rack middleware to send HTTP metrics via StatsD. A building block toward achieving Grafana Dashboard like below for a Ruby web server.

![Grafana dashboard for Ruby web server](https://mkaz.me/assets/img/external_assets/statsd_rack_instrument_dashboard.png "Grafana dashboard for Ruby web server")

## What's included

The middleware exports two metrics:
  - `rack_server_request_duration_seconds` - a histogram representing the latency of an HTTP request with the following labels:
    - `code` - the response code
    - `method` - the request method
    - `path` - the request path; stripped from any identifiers, for eg. `/resource/45646` becomes `/resource/:id`

  - `rack_server_exceptions_total` - a counter of unhandled exceptions with the following label:
    - `exception` - the class name of the error (`error.class.name`)

## Installation

1. Add this gem to your application:

```
bundle add statsd-rack-instrument
```

2. Add to your `config.ru`

```ruby
if ENV["STATSD_ADDR"].present?
  require "statsd_rack_instrument"
  use StatsDRackInstrument
end

run Rails.application # or other command for starting the app
```

3. Provide necessary env vars
  - `STATSD_ADDR` - the address of the StatsD collector
  - `STATSD_ENV` - should be set to `production`; if not provided, then StatsD will fallback to `RAILS_ENV` or `ENV`

Check <a href="https://github.com/Shopify/statsd-instrument#configuration">Configuration</a> section from the `statsd-instrument` gem for more info.


## Using with Prometheus

When combined with <a href="https://github.com/prometheus/statsd_exporter">statsd_exporter</a> it is possible to get exported metrics into Prometheus. Check out <a href="https://mkaz.me/blog/2023/collecting-metrics-from-multi-process-web-servers-the-ruby-case/">"Collecting Prometheus metrics from multi-process web servers, the Ruby case"</a> blog post discussing the idea and how to achieve it.
