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

  private

  def scrape_lonely_planet
    manual_city_links = {
      "NYC" => "/usa/new-york-city"
    }

    if manual_city_links[city_code]
      page_link = manual_city_links[city_code]
    else
      html_content = Faraday.get("https://www.lonelyplanet.com/places?q=#{city}").body
      doc = Nokogiri::HTML(html_content)
      page_link = doc.search(".card-link").first.attributes["href"].value
    end

    html_content = Faraday.get("https://www.lonelyplanet.com#{page_link}").body
    doc = Nokogiri::HTML(html_content)

    {
      link: "https://www.lonelyplanet.com#{page_link}",
      doc: doc.search(".content p, h2")
    }
  end

  def update_lonely_planet_data
    data = {}
    result = scrape_lonely_planet
    unless result[:doc].empty?
      data[:link] = result[:link]
      data[:intro] = result[:doc].first.text || ""
      data[:sections] = []
      new_section = {title: "", body: ""}
      result[:doc][1..].each do |element|
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
