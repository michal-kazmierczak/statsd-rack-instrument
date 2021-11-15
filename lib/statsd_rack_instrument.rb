require 'statsd-instrument'

class StatsDRackInstrument
  attr_reader :app

  def initialize(app)
    @app = app
  end

  def call(env) # :nodoc:
    observe(env) { @app.call(env) }
  end

  protected

  def observe(env)
    time_t0 = Time.now
    response = yield
    duration = Time.now - time_t0

    tags = {
      code: response.first.to_s,
      method: env['REQUEST_METHOD'].downcase,
      path: build_path(env)
    }
    StatsD.histogram(
      'rack_server_request_duration_seconds', duration, tags: tags
    )

    response
  rescue => e
    StatsD.increment(
      'rack_server_exceptions_total', tags: { exception: e.class.name }
    )
    raise
  end

  def build_path(env)
    strip_ids_from_path([env['SCRIPT_NAME'], env['PATH_INFO']].join)
  end

  # inspired by https://github.com/prometheus/client_ruby/blob/v2.1.0/lib/prometheus/middleware/collector.rb#L88
  def strip_ids_from_path(path)
    path.gsub(
      %r{/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}(/|$)},
      '/:uuid\\1'
    ).gsub(
      %r{/\d+(/|$)}, '/:id\\1'
    )
  end
end
