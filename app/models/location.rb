class Location < ApplicationRecord
  has_one_attached :photo
  has_many :images
  has_many :airports
end
