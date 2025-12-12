# frozen_string_literal: true

RSpec.describe Resend::Response do
  let(:data) { { id: "123", status: "sent", to: ["user@example.com"] } }
  let(:headers) { { "content-type" => "application/json", "x-ratelimit-remaining" => "50" } }
  let(:response) { described_class.new(data, headers) }

  describe "#initialize" do
    it "wraps data and headers" do
      expect(response).to be_a(Resend::Response)
    end

    it "handles nil headers" do
      response = described_class.new(data, nil)
      expect(response.headers).to eq({})
    end

    it "normalizes header keys to lowercase" do
      mixed_case_headers = { "Content-Type" => "application/json", "X-RateLimit-Remaining" => "50" }
      response = described_class.new(data, mixed_case_headers)
      expect(response.headers.keys).to all(match(/^[a-z\-]+$/))
    end
  end

  describe "#headers" do
    it "returns the response headers" do
      expect(response.headers).to eq(headers)
    end

    it "allows accessing individual headers" do
      expect(response.headers["content-type"]).to eq("application/json")
      expect(response.headers["x-ratelimit-remaining"]).to eq("50")
    end
  end

  describe "hash-like behavior" do
    describe "#[]" do
      it "accesses data like a hash" do
        expect(response[:id]).to eq("123")
        expect(response[:status]).to eq("sent")
        expect(response[:to]).to eq(["user@example.com"])
      end
    end

    describe "#[]=" do
      it "sets values like a hash" do
        response[:new_key] = "new_value"
        expect(response[:new_key]).to eq("new_value")
      end
    end

    describe "#dig" do
      it "digs into nested structures" do
        nested_data = { user: { profile: { name: "Alice" } } }
        response = described_class.new(nested_data, headers)
        expect(response.dig(:user, :profile, :name)).to eq("Alice")
      end
    end

    describe "#keys" do
      it "returns data keys" do
        expect(response.keys).to contain_exactly(:id, :status, :to)
      end
    end

    describe "#values" do
      it "returns data values" do
        expect(response.values).to include("123", "sent", ["user@example.com"])
      end
    end

    describe "#key?" do
      it "checks if key exists" do
        expect(response.key?(:id)).to be true
        expect(response.key?(:nonexistent)).to be false
      end
    end

    describe "#has_key?" do
      it "is an alias for key?" do
        expect(response.has_key?(:id)).to be true
        expect(response.has_key?(:nonexistent)).to be false
      end
    end

    describe "#to_h" do
      it "converts to plain hash" do
        expect(response.to_h).to eq(data)
      end
    end

    describe "#to_hash" do
      it "is an alias for to_h" do
        expect(response.to_hash).to eq(data)
      end
    end

    describe "#empty?" do
      it "returns false for non-empty data" do
        expect(response.empty?).to be false
      end

      it "returns true for empty data" do
        empty_response = described_class.new({}, headers)
        expect(empty_response.empty?).to be true
      end
    end
  end

  describe "enumeration" do
    describe "#each" do
      it "iterates over data" do
        result = {}
        response.each { |k, v| result[k] = v }
        expect(result).to eq(data)
      end

      it "works with enumerable methods" do
        keys = response.map { |k, _v| k }
        expect(keys).to contain_exactly(:id, :status, :to)
      end
    end
  end

  describe "#transform_keys!" do
    it "transforms keys and returns self" do
      result = response.transform_keys!(&:to_s)
      expect(result).to be(response)
      expect(response.keys).to contain_exactly("id", "status", "to")
    end
  end

  describe "method delegation" do
    it "delegates unknown methods to data hash" do
      expect(response.fetch(:id)).to eq("123")
      expect(response.slice(:id, :status)).to eq({ id: "123", status: "sent" })
    end

    it "raises NoMethodError for truly unknown methods" do
      expect { response.nonexistent_method }.to raise_error(NoMethodError)
    end
  end

  describe "#inspect" do
    it "provides useful debug output" do
      output = response.inspect
      expect(output).to include("Resend::Response")
      expect(output).to include("data=")
      expect(output).to include("headers=")
    end
  end

  describe "backwards compatibility" do
    it "behaves like the original hash response" do
      # Simulating how the old code would work
      expect(response[:id]).to eq("123")
      expect(response.dig(:status)).to eq("sent")

      # Ensure it doesn't break enumeration
      ids = []
      response.each { |k, v| ids << v if k == :id }
      expect(ids).to include("123")
    end

    it "works with RSpec matchers" do
      expect(response[:id]).to eq("123")
      expect(response).to respond_to(:headers)
    end
  end

  describe "integration with real HTTParty response" do
    it "handles HTTParty-style headers" do
      # Mock an HTTParty response object
      mock_httparty_response = double("HTTParty::Response")
      allow(mock_httparty_response).to receive(:headers).and_return({
        "Content-Type" => "application/json",
        "X-Request-Id" => "req_123"
      })

      response = described_class.new(data, mock_httparty_response)

      expect(response.headers["content-type"]).to eq("application/json")
      expect(response.headers["x-request-id"]).to eq("req_123")
    end
  end
end
