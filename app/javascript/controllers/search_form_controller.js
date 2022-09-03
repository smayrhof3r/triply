import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="search-form"
export default class extends Controller {
  connect() {
    console.log('search form controller active');

  }
  static values = {
    section: Number
  }

  static targets = ["passengerCount", "passengerGroupPartial", "city", "adults", "flexibleDateForm", "fixedDateForm"]

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

  #hasPassengerGroup() {
    console.log('there')
    let check = false
    this.passengerGroupPartialTargets.forEach((group) => {
      if (group.querySelector('.origin-city').value.length >= 3 && group.querySelector('.adults').value > 0) {
        check = true
      }
    })
    return check
  }

  #hasDates() {
    console.log(document.querySelector('.start-date').value)
    if (document.querySelector('.start-date').value) { return true }

    let hasStart = document.querySelector('.date-range-start').value
    let hasEnd = document.querySelector('.date-range-end').value
    let tripDays = document.querySelector('.trip-days').value
    console.log(`${hasStart} ${hasEnd} ${tripDays}`)
    if (hasStart && hasEnd && tripDays > 0) { return true }


    return false
  }

  #updateGroupCount() {
    this.groupCount = parseInt(this.passengerCountTarget.value) + 1
    this.passengerCountTarget.value = this.groupCount
  }

  #updateNewSectionNames() {
    console.log('updating names')
    let newSection = this.passengerGroupPartialTargets[this.passengerGroupPartialTargets.length - 1]

    newSection.querySelector('.origin-city').name = `origin_city${this.groupCount}`
    newSection.querySelector('.adults').name = `adults${this.groupCount}`
    newSection.querySelector('.children').name = `children${this.groupCount}`

    newSection.querySelector('.origin-city').id = `origin_city${this.groupCount}`
    newSection.querySelector('.adults').id = `adults${this.groupCount}`
    newSection.querySelector('.children').id = `children${this.groupCount}`
  }

  #insertPassengerGroupHTML(event) {
    console.log("adding group")
    let newPassengerGroupHTML = this.passengerGroupPartialTarget.outerHTML.replaceAll("for-removal d-none", "")
    console.log(newPassengerGroupHTML)
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
