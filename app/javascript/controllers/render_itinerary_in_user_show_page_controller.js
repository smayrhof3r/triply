import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="render-itinerary-in-user-show-page"
export default class extends Controller {

  static targets = ['itinerary']

  connect() {
    console.log(this.itineraryTarget.innerHTML);
  }

  renderItineraryPartial (event) {
    console.log(parseInt(event.currentTarget.querySelector('.itinerary').innerHTML))
    console.log(event.currentTarget.querySelector('form').action)
    event.preventDefault()
    const url = event.currentTarget.querySelector('form').action
    fetch(url, { method: "GET", headers: { "Accept": "text/plain" } })
      .then(response => response.text())
      .then((data) => {
        this.itineraryTarget.innerHTML = data
      })
    }
}
