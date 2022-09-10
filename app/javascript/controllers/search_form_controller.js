import { Controller } from "@hotwired/stimulus"
import { end } from "@popperjs/core";

// Connects to data-controller="search-form"
export default class extends Controller {

  static targets = ["passengerCount", "passengerGroupPartial", "city", "adults", "flexibleDateForm", "flexibleDatePrompt", "fixedDateForm", "fixedDatePrompt", 'startDate', 'endDate', 'startDateRange', 'endDateRange', 'oneWay']

  static values = {
    section: Number
  }

  connect() {
    console.log('search form controller active');

  }

  addPassengerGroup (event) {
    this.#insertPassengerGroupHTML(event)
    this.#updateGroupCount()
    this.#updateNewSectionNames()
  }

  updateButton() {
    let check1 = this.#hasPassengerGroup()
    let check2 = this.#hasDates()

    if (check1 && check2) {
      document.getElementById('submit').disabled = false
    } else {
      document.getElementById('submit').disabled = true
    }
  }

  revealFixedDateForm() {
    this.fixedDateFormTarget.classList.remove("v-none")
    document.querySelector(".slider-right").classList.add("slider-left")
    document.querySelector(".slider-right").classList.remove("slider-right")
    document.querySelector(".slider-down").classList.add("slider-up")
    document.querySelector(".slider-down").classList.remove("slider-down")
    this.flexibleDateFormTarget.classList.add("v-none")
  }

  revealDateRangeForm() {
    this.flexibleDateFormTarget.classList.remove("v-none")
    document.querySelector(".slider-left").classList.add("slider-right")
    document.querySelector(".slider-left").classList.remove("slider-left")
    document.querySelector(".slider-up").classList.add("slider-down")
    document.querySelector(".slider-up").classList.remove("slider-up")
    this.fixedDateFormTarget.classList.add("v-none")
  }

  setMinReturnDate() {
    if (this.startDateTarget.value) { this.endDateTarget.min = this.startDateTarget.value }
    if (this.startDateRangeTarget.value) { this.endDateRangeTarget.min = this.startDateRangeTarget.value }
  }

  hideReturnDate() {
    this.oneWayTarget.classList.add("d-none")
    console.log(this.oneWayTarget.querySelector("input"))
    this.oneWayTarget.querySelector("input").valueAsDate = null
    console.log(this.oneWayTarget.querySelector("input"))
  }

  showReturnDate() {
    this.oneWayTarget.classList.remove("d-none")
  }

  #hasPassengerGroup() {
    let check = false
    this.passengerGroupPartialTargets.forEach((group) => {
      if (group.querySelector('.origin-city').value.length >= 3 && group.querySelector('.adults').value > 0) {
        check = true
      }
    })
    return check
  }

  #hasDates() {
    if (document.querySelector('.start-date').value) {
      let not_needed = this.oneWayTarget.classList.contains("d-none")
      let date_found = document.querySelector('.end-date').value
      if ( not_needed || date_found ) {
       return true
      }
    }

    let hasStart = document.querySelector('.date-range-start').value
    let hasEnd = document.querySelector('.date-range-end').value

    let tripDays = document.querySelector('.trip-days').value
    if (hasStart && hasEnd && tripDays > 0) { return true }
    return false
  }

  #updateGroupCount() {
    this.groupCount = parseInt(this.passengerCountTarget.value) + 1
    this.passengerCountTarget.value = this.groupCount
  }

  #updateNewSectionNames() {
    let newSection = this.passengerGroupPartialTargets[this.passengerGroupPartialTargets.length - 1]

    newSection.querySelector('.origin-city').name = `origin_city${this.groupCount}`
    newSection.querySelector('.adults').name = `adults${this.groupCount}`
    newSection.querySelector('.children').name = `children${this.groupCount}`

    newSection.querySelector('.origin-city').id = `origin_city${this.groupCount}`
    newSection.querySelector('.adults').id = `adults${this.groupCount}`
    newSection.querySelector('.children').id = `children${this.groupCount}`
  }

  #insertPassengerGroupHTML(event) {
    let newPassengerGroupHTML = this.passengerGroupPartialTarget.outerHTML.replaceAll("for-removal d-none", "")
    event.currentTarget.insertAdjacentHTML("beforebegin", newPassengerGroupHTML)
  }
}
