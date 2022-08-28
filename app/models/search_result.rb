class SearchResult < ApplicationRecord
  belongs_to :flight
  belongs_to :search
  has_many :bookings
end
