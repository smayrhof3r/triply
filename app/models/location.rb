class Location < ApplicationRecord
  has_one_attached :photo
  has_many :images
  has_many :airports

  # has_many :itineraries, foreign_key: :destination_id, primary_key: :id

  def lonely_planet_data
    if lonely_planet == {}
      update_lonely_planet_data
    end
    lonely_planet
  end

  def scrape_lonely_planet
    html_content = URI.open("https://www.lonelyplanet.com/places?q=#{city}").read
    doc = Nokogiri::HTML(html_content)

    page_link = doc.search(".card-link").first.attributes["href"].value

    html_content = URI.open("https://www.lonelyplanet.com#{page_link}").read
    doc = Nokogiri::HTML(html_content)

    doc.search(".content p, h2")
  end

  private

  def update_lonely_planet_data
    data = {}
    result = scrape_lonely_planet
    unless result.empty?
      data[:intro] = result.first.text
      data[:sections] = []
      new_section = {}
      result[1..].each do |element|
        if element.name == "h2"
          data[:sections] << new_section unless new_section[:title].empty? || new_section[:body].empty?
          new_section = { title: element.text, body: ""}
        else
          new_section[:body] += "\n\n #{element.text}"
        end
      end
    end
    self.update_attribute(:lonely_planet, data)
  end
end
