class Booking < ApplicationRecord
  belongs_to :passenger_group
  has_one :flight
  belongs_to :search_result
end
