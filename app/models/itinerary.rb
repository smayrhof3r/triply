class Itinerary < ApplicationRecord
  # belongs_to :location, foreign_key: :destination_id
  has_many :passenger_groups #, dependent: :destroy
  has_many :permissions #, dependent: :destroy
  has_many :users, through: :permissions

  def self.delete_unclaimed(ids = [])

    sql = "
    SELECT itineraries.id as i, permissions.id as pe_id, passenger_groups.id as p, bookings.id as b
    FROM
    itineraries
    LEFT JOIN permissions ON permissions.itinerary_id = itineraries.id
    LEFT JOIN passenger_groups ON passenger_groups.itinerary_id = itineraries.id
    LEFT JOIN bookings ON bookings.passenger_group_id = passenger_groups.id
    WHERE permissions.id IS NULL"
    # ,

    sql += " and itineraries.id in (#{ids.join(',')})" unless ids.empty?

    result = ActiveRecord::Base.connection.execute(sql)

    unless result.ntuples == 0
      self.delete_sql('bookings', result.map{|r| r["b"]}.uniq)
      self.delete_sql('passenger_groups', result.map{|r| r["p"]}.uniq)
      self.delete_sql('itineraries', result.map{|r| r["i"]}.uniq)
    end

    result
  end

  def destination
    Location.find(destination_id)
  end

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

  private
  def self.delete_sql(table, ids)
    sql = "DELETE FROM #{table} WHERE id in (#{ids.join(',')})"
    ActiveRecord::Base.connection.execute(sql) unless ids.join(',').empty?
  end

end
