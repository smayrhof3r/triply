class Booking < ApplicationRecord
  belongs_to :passenger_group
  belongs_to :search_result

end
