require 'httparty'
require 'base64'

class SendRequestDetails
  API_URL = 'https://api-inference.huggingface.co/models/black-forest-labs/FLUX.1-schnell'

  def self.call(request)
    new(request).perform
  end

  def initialize(request)
    @request = request
    @api_key = ENV['API_KEY'] # Fetch the API key from the .env file
  end

  def perform
    raise "Request or API key is missing" unless @request && @api_key

    request_data = extract_request_details
    response_data = call_api(request_data)
    raise "API call failed, no response received" unless response_data

    save_image(response_data)
  rescue StandardError => e
    Rails.logger.error "Error occurred: #{e.message}"
    raise e # Re-raise the exception to allow Rails to handle it (optional)
  end

  private

  def extract_request_details
    {
      inputs: @request.prompt
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
    sleep(6)

    if response.success?
      Rails.logger.info "API Response: Successfully received image data"
      response.body # This assumes the API response is raw image bytes
    else
      Rails.logger.error "API Request Failed: #{response.code} - #{response.body}"
      @request.create_request_response(metadata:JSON.parse(response.body))
      raise "API Request Failed with status #{response.code}"
    end
  end
  def save_image(response_data)
    Rails.logger.info "Attaching Image to RequestResponse..."
    @request_response = @request.create_request_response

    @request_response.image.attach(
      io: StringIO.new(response_data),
      filename: "generated_image.png",
      content_type: "image/png"
    )

    if @request_response.image.attached?
      Rails.logger.info "Image attached successfully to RequestResponse ID: #{@request_response.id}"
    else
      raise "Failed to attach image to RequestResponse"
    end
  rescue => e
    Rails.logger.error "Error attaching image: #{e.message}"
    raise e
  end
end
