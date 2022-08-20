class Flight < ApplicationRecord
  has_many :bookings
  has_many :locations, through: :aiports
end
