class Location < ApplicationRecord
  has_one_attached :photo
  has_many :images
  has_many :airports

  has_many :itineraries #, foreign_key: :destination_id, primary_key: :id
end
