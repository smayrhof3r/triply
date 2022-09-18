import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="render-itinerary-in-user-show-page"
export default class extends Controller {

  static targets = ['itinerary']

  connect() {
  }

  renderItineraryPartial (event) {
    const url = event.currentTarget.querySelector('form').action
    console.log(url)
    fetch(url, { method: "GET", headers: { "Accept": "text/plain" } })
      .then(response => response.text())
      .then((data) => {
        this.itineraryTarget.innerHTML = data
      })
    }
}
