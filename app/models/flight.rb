class Flight < ApplicationRecord
  has_many :bookings
  has_many :airports
end
