class SendRequestDetails
  def self.call(request)
    new(request).perform
  end

  def initialize(request)
    @request = request
  end

  def perform
    return unless @request

    # Extract request details
    request_data = extract_request_details

    # Send details (e.g., log or external API call)
    response_data =  call_api(request_data)
  end

  private

  def extract_request_details
    {
      prompt: @request.prompt
    }
  end

  def call_api(data)
    # Example: Log the details (replace with your logic for sending data)
    Rails.logger.info "Sending Request Details: #{data.to_json}"

    # If sending to an external API, you can use an HTTP client here
    # Example:
    # HTTParty.post("https://example.com/api", body: data.to_json, headers: { "Content-Type": "application/json" })
  end
end
