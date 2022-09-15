import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="confirm-booking"
export default class extends Controller {

  static targets = ['form']

  connect() {
    // console.log(this.bookingTarget.innerHTML);
  }

  updateBooking (event) {
    console.log(5)
    console.log(new FormData(this.formTarget))
    event.preventDefault()
    const url = this.formTarget.action

    fetch(url, { 
      method: "PATCH", 
      headers: { "Accept": "text/plain" },
      body: new FormData(this.formTarget)
    })
    .then(response => response.text() )
    .then((data) => {
      console.log(data)
    })
      
  }

  #bookingNotConfirmed () {

  }

  #bookingConfirmed () {

  }

}
