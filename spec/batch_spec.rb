# frozen_string_literal: true

RSpec.describe "Batch" do
  describe "#send" do

    before do
      Resend.api_key = "re_123"
    end

    it "should send email" do
      resp = {
        "data": [
          {
            "id": "ae2014de-c168-4c61-8267-70d2662a1ce1"
          },
          {
            "id": "faccb7a5-8a28-4e9a-ac64-8da1cc3bc1cb"
          }
        ]
      }

      params = [
        {
          "from": "from@e.io",
          "to": ["email1@email.com"],
          "text": "testing",
          "subject": "Hey",
        },
        {
          "from": "from@e.io",
          "to": ["email2@email.com"],
          "text": "testing",
          "subject": "Hello",
        },
      ]
      allow_any_instance_of(Resend::Request).to receive(:perform).and_return(resp)
      emails = Resend::Batch.send(params)
      expect(emails[:data].length).to eq 2
    end
  end
end
