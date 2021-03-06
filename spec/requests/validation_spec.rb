require 'rails_helper'

describe "validation" do
  include GdsApi::TestHelpers::PublishingApi

  let(:malformed_json) { "[" }
  let(:headers) { { 'Content-Type' => 'application/json', 'HTTP_AUTHORIZATION' => 'Bearer 12345678' } }
  let(:manual_without_title)  { valid_manual.tap {|m| m.delete("title") } }
  let(:section_without_title) { valid_section.tap {|m| m.delete("title") } }

  context "for manuals" do
    it "detects malformed JSON" do
      put '/hmrc-manuals/imaginary-slug', malformed_json, headers

      expect(response.status).to eq(400)
      expect(json_response).to include("status" => "error")
      expect(json_response["errors"].first).to match(%r{Request JSON could not be parsed:})
    end

    it "validates for the presence of the title" do
      put_json '/hmrc-manuals/imaginary-slug', manual_without_title

      expect(response.status).to eq(422)
      expect(json_response).to include("status" => "error")
      expect(json_response["errors"].first).to match(%r{The property '#/' did not contain a required property of 'title' in schema})
    end

    context 'manuals with images' do
      it 'rejects manuals with Markdown images not on assets.digital.cabinet-office.gov.uk' do
        manual = valid_manual
        manual['description'] = '![Manual](http://upload.wikimedia.org/wikipedia/commons/e/ef/Icono_Normativa.png)'
        put_json '/hmrc-manuals/imaginary-slug', manual, headers

        expect(response.status).to eq(422)
      end

      it 'rejects manuals with HTML images not on assets.digital.cabinet-office.gov.uk' do
        manual = valid_manual
        manual['description'] = '<img src="http://upload.wikimedia.org/wikipedia/commons/e/ef/Icono_Normativa.png" alt="Manual"/>'
        put_json '/hmrc-manuals/imaginary-slug', manual, headers

        expect(response.status).to eq(422)
      end

      it 'allows images with a relative path' do
        stub_default_publishing_api_put

        manual = valid_manual
        manual['description'] = '![Manual](/path/to/image.png)'
        put_json '/hmrc-manuals/imaginary-slug', manual, headers

        expect(response.status).to eq(200)
      end
    end
  end

  context "for manual sections" do
    it "detects malformed JSON" do
      put '/hmrc-manuals/imaginary-slug/sections/imaginary-section', malformed_json, headers

      expect(response.status).to eq(400)
      expect(json_response).to include("status" => "error")
      expect(json_response["errors"].first).to match(%r{Request JSON could not be parsed:})
    end

    it "validates for the presence of the title" do
      put_json '/hmrc-manuals/imaginary-slug/sections/imaginary-section', section_without_title

      expect(response.status).to eq(422)
      expect(json_response).to include("status" => "error")
      expect(json_response["errors"].first).to match(%r{The property '#/' did not contain a required property of 'title' in schema})
    end
  end
end
