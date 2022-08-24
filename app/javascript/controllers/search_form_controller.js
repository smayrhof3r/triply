import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="search-form"
export default class extends Controller {
  connect() {
    console.log('search form controller active');

  }
  static values = {
    section: Number
  }

  static targets = ["passengerCount", "passengerGroupPartial"]

  toggleCollapse (event) {
    this.section = document.getElementById(`${event.currentTarget.id}Parent`)
    this.icon = this.section.querySelector("i")
    this.header = this.section.querySelector(".card-header")
    this.body = this.section.querySelector(".collapse")
    this.collapsed = this.icon.classList.contains("fa-plus")

    this.collapsed ? this.#openSection() : this.#closeSection()
  }

  addPassengerGroup (event) {
    let newPassengerGroup = this.passengerGroupPartialTarget.outerHTML
    event.currentTarget.insertAdjacentHTML("beforebegin", newPassengerGroup)
    this.passengerCountTarget.value = parseInt(this.passengerCountTarget.value) + 1
  }

  #openSection () {
    this.icon.classList.add("fa-minus")
    this.icon.classList.remove("fa-plus")
    this.header.classList.remove("rounded", "bg-secondary")
    this.header.classList.add("bg-success")
    this.body.classList.add("show")
  }

  #closeSection () {
    this.icon.classList.remove("fa-minus")
    this.icon.classList.add("fa-plus")
    this.header.classList.add("rounded","bg-secondary")
    this.header.classList.remove("bg-success")
    this.body.classList.remove("show")
  }
}
