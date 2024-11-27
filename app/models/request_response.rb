class RequestResponse < ApplicationRecord
  belongs_to :request
  serialize :image_urls, Array

end
