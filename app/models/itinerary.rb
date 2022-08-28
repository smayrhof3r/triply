class Itinerary < ApplicationRecord
  belongs_to :location, foreign_key: :destination_id, primary_key: :id
  has_many :passenger_groups, dependent: :destroy
  has_many :permissions, dependent: :destroy
  has_many :users, through: :permissions

  def total_cost
    total = 0
    passenger_groups.each do |p|
      b = Booking.find_by(status: "suggested", passenger_group: p)
      total += b.search_result.cost_per_head if b
    end
    total.round(2)
  end
end
