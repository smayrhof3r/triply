import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="confirm-booking"
export default class extends Controller {

  static targets = ['booking','form']

  connect() {
    // console.log(this.bookingTarget.innerHTML);
    console.log('booking stimulus6');
  }

  updateBooking (event) {
    event.preventDefault()
    const form = document.getElementById(`edit_booking_${event.currentTarget.name}`)
    const url = form.action
    console.log(url)
    fetch(url, {
      method: "PATCH",
      headers: { "Accept": "text/plain" },
      body: new FormData(form)
    })
    .then(response => response.text() )
    .then((data) => {
      this.bookingTarget.outerHTML = data
    })
  }
}
