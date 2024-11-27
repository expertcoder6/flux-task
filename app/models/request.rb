class Request < ApplicationRecord
  has_one :product, dependent: :destroy
  has_one :request_response, dependent: :destroy

  validates :prompt, presence: true

  after_create :process_prompt

  private

  def process_prompt
    url = extract_url_from_prompt
    return unless url

    Product.create(link: url, request: self)
  end

  def extract_url_from_prompt
    URI.extract(prompt, ["http", "https"]).first
  rescue StandardError
    nil
  end
end
