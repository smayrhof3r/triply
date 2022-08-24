import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="remove-section"
export default class extends Controller {
  connect() {
    console.log("hello from removeSection")
  }

  static targets = ["section"]
  remove (event) {
    this.sectionTarget.outerHTML = ""
  }
}
