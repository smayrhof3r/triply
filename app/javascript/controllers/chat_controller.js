import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="chat"
export default class extends Controller {
  connect() {
    console.log("chat stimulus active 2")
  }
  static targets = ['showIcon', 'hideIcon', 'messageBox']

  toggle(event) {
    this.showIconTarget.classList.toggle("d-none")
    this.hideIconTarget.classList.toggle("d-none")
    this.messageBoxTarget.classList.toggle("d-none")
  }
}
