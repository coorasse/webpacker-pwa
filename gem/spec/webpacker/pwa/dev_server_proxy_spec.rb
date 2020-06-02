require 'spec_helper'
require "rails/railtie"

RSpec.describe Webpacker::Pwa::DevServerProxy do
  let(:app) { double(:app, call: 'hello') }
  let(:instance) { described_class.new(app) }
  let(:params) { { 'PATH_INFO' => requested_resource, "REQUEST_METHOD" => "GET" } }
  subject(:response) { instance.call(params) }

  before do
    allow(Rails).to receive(:root).and_return(Pathname.pwd.join('spec/dummy-rails-app'))
    allow(Rails).to receive(:env).and_return(double(:env, test?: false, development?: true, production?: false, presence_in: 'development'))
    allow(Socket).to receive(:tcp).and_return(double(:socket, close: true))
  end

  context 'when receives a request for a service-worker' do
    let(:requested_resource) { '/service-worker.js' }

    it 'proxies the request' do
      expect { response }.to raise_exception(Errno::ECONNREFUSED)
    end
  end

  context 'when receives a request for anything else' do
    let(:requested_resource) { '/groups/1' }

    it 'does not proxy the request' do
      expect(response).to eq('hello')
    end
  end
end
