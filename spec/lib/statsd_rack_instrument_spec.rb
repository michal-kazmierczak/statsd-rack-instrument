require 'rack/test'
require './lib/statsd_rack_instrument'

describe StatsDRackInstrument do
  include Rack::Test::Methods

  let(:generic_app) do
    ->(_) { [200, { 'Content-Type' => 'text/html' }, ['OK']] }
  end

  let!(:app) do
    described_class.new(generic_app)
  end

  it 'returns the app response' do
    get '/foo'

    expect(last_response).to be_ok
    expect(last_response.body).to eql('OK')
  end

  it 'records request_duration_seconds metrics' do
    expected_tags = {
      code: '200',
      method: 'get',
      path: '/'
    }
    expect(StatsD).to receive(:histogram).with(
      'rack_server_request_duration_seconds',
      kind_of(Numeric),
      tags: expected_tags
    )

    get '/'

    expect(last_response).to be_ok
  end

  it 'replaces a numeric id from the requested path' do
    expected_tags = {
      code: '200',
      method: 'post',
      path: '/foo/:id/bar'
    }
    expect(StatsD).to receive(:histogram).with(
      'rack_server_request_duration_seconds',
      kind_of(Numeric),
      tags: expected_tags
    )

    post '/foo/123/bar'

    expect(last_response).to be_ok
  end

  it 'replaces UUID from the requested path' do
    expected_tags = {
      code: '200',
      method: 'post',
      path: '/foo/:uuid/bar'
    }
    expect(StatsD).to receive(:histogram).with(
      'rack_server_request_duration_seconds',
      kind_of(Numeric),
      tags: expected_tags
    )

    post '/foo/d6ddfcda-4773-11ee-be56-0242ac120002/bar'

    expect(last_response).to be_ok
  end

  it 'replaces Mongo ObjectId from the requested path' do
    expected_tags = {
      code: '200',
      method: 'post',
      path: '/foo/:object-id/bar'
    }
    expect(StatsD).to receive(:histogram).with(
      'rack_server_request_duration_seconds',
      kind_of(Numeric),
      tags: expected_tags
    )

    post '/foo/64c8f722b1021f00105eeba3/bar'

    expect(last_response).to be_ok
  end

  it 'replaces params from the requested path and removes query params' do
    expected_tags = {
      code: '200',
      method: 'post',
      path: '/foo/:id/bar'
    }
    expect(StatsD).to receive(:histogram).with(
      'rack_server_request_duration_seconds',
      kind_of(Numeric),
      tags: expected_tags
    )

    post '/foo/123/bar?query_param=query_value'

    expect(last_response).to be_ok
  end

  context 'when app raises an uncaught exception' do
    let(:generic_app) do
      ->(_) { raise RuntimeError }
    end

    it 'replaces params from the requested path' do
      expected_tags = { exception: 'RuntimeError' }

      expect(StatsD).to receive(:increment).with(
        'rack_server_exceptions_total', tags: expected_tags
      )

      expect { get '/' }.to raise_error RuntimeError
    end
  end
end
