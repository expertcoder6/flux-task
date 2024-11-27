class SendRequestDetails
  def self.call(request)
    new(request).perform
  end

  def initialize(request)
    @request = request
  end

  def perform
    return unless @request

    request_data = extract_request_details

    response_data =  call_api(request_data)
  end

  private

  def extract_request_details
    {
      prompt: @request.prompt
    }
  end

  def call_api(data)
    Rails.logger.info "Sending Request Details: #{data.to_json}"

    # HTTParty.post("https://example.com/api", body: data.to_json, headers: { "Content-Type": "application/json" })
  end
end
