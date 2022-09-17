import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="confirm-booking"
export default class extends Controller {

  static targets = ['booking','form']

  connect() {
    // console.log(this.bookingTarget.innerHTML);
  }

  updateBooking (event) {
    event.preventDefault()
    const url = this.formTarget.action

    fetch(url, { 
      method: "PATCH", 
      headers: { "Accept": "text/plain" },
      body: new FormData(this.formTarget)
    })
    .then(response => response.text() )
    .then((data) => {
      this.bookingTarget.outerHTML = data
    })     
  }
}
