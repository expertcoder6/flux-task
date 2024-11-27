require 'httparty'
require 'base64'

class SendRequestDetails
  API_URL = 'https://api.aimlapi.com/images/generations'

  def self.call(request)
    new(request).perform
  end

  def initialize(request)
    @request = request
    @api_key = ENV['API_KEY'] # Fetch from .env
  end

  def perform
    return unless @request && @api_key

    request_data = extract_request_details
    response_data = call_api(request_data)
    save_image(response_data) if response_data
  end

  private

  def extract_request_details
    {
      prompt: @request[:prompt],
      model: 'flux/dev'
    }
  end

  def call_api(data)
    Rails.logger.info "Sending Request Details: #{data.to_json}"

    response = HTTParty.post(
      API_URL,
      body: data.to_json,
      headers: {
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{@api_key}"
      }
    )

    if response.success?
      Rails.logger.info "API Response: #{response.body}"
      JSON.parse(response.body)
    else
      Rails.logger.error "API Request Failed: #{response.code} - #{response.body}"
      JSON.parse(response.body)
    end
  end

  def save_image(response_data)
    if response_data['statusCode']==400
    @request.create_request_response(metadata: response_data)
    elsif response_data['statusCode']== 200 || response_data['statusCode']== 201
      @request.create_request_response(metadata: response_data)
    end
  end
end
