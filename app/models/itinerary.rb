class Itinerary < ApplicationRecord
  has_one :location
  has_many :passenger_groups, dependent: :destroy
  has_many :permissions, dependent: :destroy
  has_many :users, through: :permissions
end
