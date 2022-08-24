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
    console.log(5)
    this.#insertPassengerGroupHTML(event)
    this.#updateGroupCount()
    this.#updateNewSectionNames()
  }

  updateButton() {
    console.log('button check..')
    if (this.#hasPassengerGroup() && this.#hasDates()) {
      document.getElementById('submit').disabled = false
    } else {
      document.getElementById('submit').disabled = true
    }
  }

  #hasPassengerGroup() {
    return true
  }

  #hasDates() {
    return true
  }

  #updateGroupCount() {
    this.groupCount = parseInt(this.passengerCountTarget.value) + 1
    this.passengerCountTarget.value = this.groupCount
  }

  #updateNewSectionNames() {
    let newSection = this.passengerGroupPartialTargets[this.passengerGroupPartialTargets.length - 1]

    newSection.querySelector('.origin-city').name = `origin_city${this.groupCount}`
    newSection.querySelector('.adults').name = `adults${this.groupCount}`
    newSection.querySelector('.adults').name = `children${this.groupCount}`

    newSection.querySelector('.origin-city').id = `origin_city${this.groupCount}`
    newSection.querySelector('.adults').id = `adults${this.groupCount}`
    newSection.querySelector('.adults').id = `children${this.groupCount}`
  }

  #insertPassengerGroupHTML(event) {
    let newPassengerGroupHTML = this.passengerGroupPartialTarget.outerHTML.replaceAll("for-removal d-none", "")
    event.currentTarget.insertAdjacentHTML("beforebegin", newPassengerGroupHTML)
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
