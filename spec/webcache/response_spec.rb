require 'spec_helper'

describe WebCache::Response do
  describe '#new' do
    context "with hash" do
      let :response do
        described_class.new({ 
          error: 'problemz', 
          base_uri: 'sky.net', 
          content: 'robots' 
        })
      end

      it "sets error" do
        expect(response.error).to eq 'problemz'
      end

      it "sets base_uri" do
        expect(response.base_uri).to eq 'sky.net'
      end

      it "sets content" do
        expect(response.content).to eq 'robots'
      end
    end

    context "with open uri" do
      let :response do
        described_class.new OpenStruct.new base_uri: 'sky.net', read: 'robots'
      end
      
      it "sets error" do
        expect(response.error).to be nil
      end

      it "sets base_uri" do
        expect(response.base_uri).to eq 'sky.net'
      end

      it "sets content" do
        expect(response.content).to eq 'robots'
      end
    end
  end

  describe '#to_s' do
    let :response do
      described_class.new content: 'robots'
    end

    it "returns the content" do
      expect(response.to_s).to eq 'robots'
    end
  end
end
