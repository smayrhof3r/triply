# Triply
## ✈️ What this app does
Triply is a travel site for finding the best flights and destinations for a group coming from multiple destinations. If you have family overseas and are always struggling to figure out the best place to meet, with decent flights for everyone, then this site is for you!


## ⭐ Key features
- Users input the details of their travel groups
- Search feature queries the API for real flights from each starting point to various destinations
- Results are sorted by price or duration, and flights are stored for the cheapest and shorted flight options. 
- Users can explore destinations, where they are able to see more information about the destination (sourced from lonely planet using web scraping). 
- Once users choose a destination and 'add' it to their itineraries, they are able to confirm the flights they will be taking.
- Users can navigate to their itineraries and edit the flights, as well as share the itinerary with other users so they can select the flights for their own travel groups (eg. I can share the itinerary with my family in Nice and they can select their flights from Nice to the destination themselves) 


## 🌐 APIs
- Amadeus API
- Web scraping from LonelyPlanet.com

## Technology Stack
Ruby on Rails, using
Ruby
AJAX
Javascript
APIs

## Outstanding issues or additional features to build in the future
- ability to set a date range for when you want to come and go
- ability to choose from other flight options (besides the preselected cheapest and shortest)

## Limitations
- The API is very very slow to use. It's a testing API with limited calls, but the site also makes many calls for one search (every combination of starting and end point is a separate API call). To be really useful, the tool needs to be able to either reduce the number of API calls or run these in parallel instead of consecutively. This is not currently possible, so while a search will work, it takes a very long time to complete. 
- The application does not currently have functionality for actually booking the flights. While the flight data is real, the functionality to book real flights is beyond the scope of this project. 
