# frozen_string_literal: true

RSpec.describe "Segments" do

  describe "create segment" do

    before do
      Resend.configure do |config|
        config.api_key = "re_123"
      end
    end

    it "should create a segment record" do
      resp = {
        "object": "audience",
        "id": "78261eea-8f8b-4381-83c6-79fa7120f1cf",
        "name": "Registered Users"
      }
      params = {
        "name": "Registered Users",
      }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      segment = Resend::Segments.create(params)
      expect(segment[:id]).to eql("78261eea-8f8b-4381-83c6-79fa7120f1cf")
      expect(segment[:name]).to eql("Registered Users")
      expect(segment[:object]).to eql("audience")
    end
  end

  describe "get segment" do
    it "should retrieve segment" do
      resp = {
        "object": "audience",
        "id": "78261eea-8f8b-4381-83c6-79fa7120f1cf",
        "name": "Registered Users",
        "created_at": "2023-10-06 22:59:55.977+00"
      }
      allow(resp).to receive(:body).and_return(resp)
      allow(HTTParty).to receive(:send).and_return(resp)

      segment = Resend::Segments.get(resp[:id])

      expect(segment[:object]).to eql "audience"
      expect(segment[:id]).to eql "78261eea-8f8b-4381-83c6-79fa7120f1cf"
      expect(segment[:name]).to eql "Registered Users"
      expect(segment[:created_at]).to eql "2023-10-06 22:59:55.977+00"
    end
  end

  describe "update segment" do
    it "should update segment" do
      resp = { "object": "segment", "id": "78261eea-8f8b-4381-83c6-79fa7120f1cf" }
      params = { "segment_id": "78261eea-8f8b-4381-83c6-79fa7120f1cf", "name": "Registered Users - Updated" }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      segment = Resend::Segments.update(params)
      expect(segment[:object]).to eql("segment")
      expect(segment[:id]).to eql("78261eea-8f8b-4381-83c6-79fa7120f1cf")
    end
    it "should use PATCH segments/:segment_id and exclude segment_id from the body" do
      params = { segment_id: "78261eea-8f8b-4381-83c6-79fa7120f1cf", name: "Registered Users - Updated" }
      req = double("req", perform: { id: params[:segment_id] })
      expect(Resend::Request).to receive(:new).once do |path, body, verb|
        expect(path).to eql("segments/#{params[:segment_id]}")
        expect(verb).to eql("patch")
        expect(body).not_to have_key(:segment_id)
        expect(body[:name]).to eql("Registered Users - Updated")
        req
      end
      Resend::Segments.update(params)
    end
  end

  describe "list segments" do
    it "should list segments" do
      resp = {
        "object": "list",
        "data": [
          {
            "id" => "78261eea-8f8b-4381-83c6-79fa7120f1cf",
            "name" => "Registered Users",
            "created_at" => "2023-10-06 22:59:55.977+00"
          }
        ]
      }
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      segments = Resend::Segments.list
      expect(segments[:object]).to eql "list"
      expect(segments[:data].empty?).to be false
      expect(segments[:data].length).to eql(1)
      expect(segments[:data].first["id"]).to eql("78261eea-8f8b-4381-83c6-79fa7120f1cf")
      expect(segments[:data].first["name"]).to eql("Registered Users")
    end
  end

  describe "remove segment" do
    it "should remove segment by id" do

      resp = {
        "object": "audience",
        "id": "78261eea-8f8b-4381-83c6-79fa7120f1cf",
        "deleted": true
      }

      allow(resp).to receive(:body).and_return(resp)
      allow(HTTParty).to receive(:send).and_return(resp)

      deleted = Resend::Segments.remove("78261eea-8f8b-4381-83c6-79fa7120f1cf")
      expect(deleted[:object]).to eql("audience")
      expect(deleted[:id]).to eql("78261eea-8f8b-4381-83c6-79fa7120f1cf")
      expect(deleted[:deleted]).to be true
    end
  end
end
