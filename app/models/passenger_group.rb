class PassengerGroup < ApplicationRecord
  belongs_to :itinerary
  has_many :bookings #, dependent: :destroy
end
