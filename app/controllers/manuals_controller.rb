class ManualsController < ApplicationController
  before_filter :parse_request_body, only: [:update]

  def update
    manual = PublishingAPIManual.new(params[:id], @parsed_request_body)
    begin
      publishing_api_response = manual.save!
      respond_to do |format|
        format.json { render json: { govuk_url: manual.govuk_url },
                    status: publishing_api_response.code,
                    location: manual.govuk_url }
      end
    rescue ActionController::UnknownFormat
      render json: { status: "error", errors: ["Invalid Accept header"] }, status: 406
    rescue ValidationError
      render json: { status: "error", errors: manual.errors.full_messages }, status: 422
    end
  end
end
