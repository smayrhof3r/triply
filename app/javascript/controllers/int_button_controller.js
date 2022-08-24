import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="int-button"
export default class extends Controller {
  connect() {
    console.log("hello from int button")
  }

  static targets = ["integer", "form"]

  updateMinus (event) {
    if (parseInt(this.integerTarget.innerHTML) >= 1) {
      const newValue = parseInt(this.integerTarget.innerHTML) - 1
      this.integerTarget.innerHTML = newValue
      this.formTarget.value = newValue
    }
  }

  updatePlus (event) {
    const newValue = parseInt(this.integerTarget.innerHTML) + 1
    this.integerTarget.innerHTML = newValue
    this.formTarget.value = newValue
  }

}
