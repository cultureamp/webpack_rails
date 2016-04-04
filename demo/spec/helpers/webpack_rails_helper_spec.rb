require 'rails_helper'

RSpec.describe WebpackRails::Helper, type: :helper do
  describe '#webpack_bundle_asset' do
    let(:bundle_filename) { 'asdf' }
    let(:webpack_rails_task) { spy('WebpackRails::Task') }
    let(:base_config) do
      {
        dev_server: true,
        protocol: '1',
        host: '2',
        port: '3',
      }
    end
    let(:config) { base_config }
    subject { helper.webpack_bundle_asset(bundle_filename) }

    before(:each) do
      allow(helper).to receive(:webpack_rails_config).and_return(config)
      allow(helper).to receive(:webpack_rails_task).and_return(webpack_rails_task)
    end

    describe 'when dev server is enabled' do
      let(:config) { base_config.merge(dev_server: true) }

      it 'returns dev server url' do
        expect(subject).to eq('1://2:3/asdf')
      end
    end

    describe 'when dev server is disabled' do
      let(:config) { base_config.merge(dev_server: false) }

      it 'returns input bundle filename' do
        expect(subject).to eq(bundle_filename)
        expect(webpack_rails_task).to have_received(:run_webpack).with(config)
      end
    end

    describe 'when sprockets integration is enabled' do
      let(:config) { base_config.merge(sprockets_integration: true) }

      it 'does not run webpack' do
        subject
        expect(webpack_rails_task).not_to have_received(:run_webpack)
      end
    end

    describe 'when sprockets integration is disabled' do
      let(:config) { base_config.merge(sprockets_integration: false) }

      it 'runs webpack' do
        subject
        expect(webpack_rails_task).to have_received(:run_webpack)
      end
    end
  end
end
