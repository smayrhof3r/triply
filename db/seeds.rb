# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
locations = [
  ['Paris', 'France', 'Europe'],
  ['New York', 'USA', 'North America'],
  ['London', 'England', 'Europe'],
  ['Bangkok', 'Thailand', 'Asia'],
  ['Hong Kong', 'China', 'Asia'],
  ['Dubai', 'UAE', 'Middle East'],
  ['Singapore', 'Singapore', 'Asia'],
  ['Rome', 'Italy', 'Europe'],
  ['Macau', 'Portugal', 'Europe'],
  ['Istanbul', 'Turkey', 'Europe'],
  ['Kuala Lumpur', 'Malaysia', 'Asia'],
  ['Delhi', 'India', 'Asia'],
  ['Tokyo', 'Japan', 'Asia'],
  ['Antalya', 'Turkey', 'Asia'],
  ['Mexico City', 'Mexico', 'North America'],
  ['Moscow', 'Russia', 'Asia'],
  ['Porto', 'Portugal', 'Europe'],
  ['San Francisco', 'USA', 'North America'],
  ['Beijing', 'China', 'Asia'],
  ['Los Angelos', 'USA', 'North America'],
  # ['Chicago', 'USA', 'North America'],
  # ['Barcelona', 'Spain', 'Europe'],
  # ['Abu Dhabi', 'UAE', 'Middle East'],
  # ['Amsterdam', 'Netherlands', 'Europe'],
  # ['Madrid', 'Spain', 'Europe'],
  # ['Sydney', 'Australia', 'Asia'],
  # ['San Miguel de Allende', 'Mexico', 'North America'],
  # ['Lisbon', 'Portugal', 'Europe'],
  # ['Vienna', 'Austria', 'Germany'],
  # ['Johannesburg', 'South Africa', 'Africa']
]


locations.each do |location|
  l = Location.create(city: location[0], country: location[1], region: location[2])
  photos = Unsplash::Photo.search(location[0])
                          .first(5)
                          .map { |result| result.urls["raw"] }
  photos.each do |photo|
    i = Image.create(url: photo, location: l)
  end

  puts l
end
