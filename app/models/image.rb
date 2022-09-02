class Image < ApplicationRecord
  belongs_to :location # , dependent: :destroy

  def self.retrieve_all_by_itinerary(itineraries=[])

    unless itineraries.empty?
      sql = "
      SELECT itineraries.id as id, images.url as url
      FROM images
      INNER JOIN locations ON images.location_id = locations.id
      INNER JOIN itineraries ON itineraries.destination_id = locations.id
      WHERE itineraries.id in (#{itineraries.map{|i| i.id}.join(',')})"
      @result = ActiveRecord::Base.connection.execute(sql)

      @result_mapped=@result.map do |r|
        [r["id"], r["url"]]
      end.to_h

      return @result_mapped
    end

    {}

  end
end
