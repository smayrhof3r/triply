class Booking < ApplicationRecord
  belongs_to :passenger_group
  belongs_to :flight
end
