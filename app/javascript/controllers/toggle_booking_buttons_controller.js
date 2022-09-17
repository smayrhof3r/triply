import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="toggle-booking-buttons"
export default class extends Controller {
  connect() {
    console.log('toggle booking button controller')
  }


  static targets = ['bookingButton']

  enableButtons() {
    console.log('enabling booking buttons')
    this.bookingButtonTargets.forEach((button)=>{
      console.log(button)
      button.classList.remove('disabled')
    })
  }
}
