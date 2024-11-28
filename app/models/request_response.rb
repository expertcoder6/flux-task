class RequestResponse < ApplicationRecord
  belongs_to :request
  has_one_attached :image

end
