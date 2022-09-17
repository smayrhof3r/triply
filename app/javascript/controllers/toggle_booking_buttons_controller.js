import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="toggle-booking-buttons"
export default class extends Controller {
  connect() {
  }


  static targets = ['bookingButton']

  enableButtons() {
    this.bookingButtonTargets.forEach((button)=>{
      button.classList.remove('disabled')
    })
  }
}
