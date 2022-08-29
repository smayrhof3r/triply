class Itinerary < ApplicationRecord
  belongs_to :location # foreign_key: :destination_id
  has_many :passenger_groups #, dependent: :destroy
  has_many :permissions #, dependent: :destroy
  has_many :users #, through: :permissions

  def total_cost
    total = 0
    passenger_groups.each do |p|
      b = Booking.find_by(status: "suggested", passenger_group: p)
      total += b.search_result.cost_per_head * (p.adults + p.children) if b
    end
    total
  end

  def avg_cost
    total_cost / passenger_groups.map { |p| p.adults + p.children }.sum
  end
end
