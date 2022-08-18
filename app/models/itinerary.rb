class Itinerary < ApplicationRecord
  has_one :location
  has_many :passenger_groups
  has_many :permissions
  has_many :users, through: :permissions
end
