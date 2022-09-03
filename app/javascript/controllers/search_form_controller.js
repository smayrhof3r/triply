import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="search-form"
export default class extends Controller {
  static targets = ["passengerCount", "passengerGroupPartial", "city", "adults"]
  static values = {
    section: Number
  }
  connect() {
    console.log('search form controller active');
    console.log(this.passengerGroupPartialTargets);

  }



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

  #hasPassengerGroup() {
    console.log('group check')

    let check = false
    this.passengerGroupPartialTargets.forEach((group) => {
      console.log(group)
      console.log(group.querySelector('.origin-city'))
      if (group.querySelector('.origin-city').value.length >= 3 && group.querySelector('.adults').value > 0) {
        check = true
      }
    })
    console.log('passenger groups ok')
    return check
  }

  #hasDates() {
    console.log('date check')
    console.log(document.querySelector('.start-date').value)

    if (document.querySelector('.start-date').value && document.querySelector('.end-date').value) { return true }

    let hasStart = document.querySelector('.date-range-start').value
    let hasEnd = document.querySelector('.date-range-end').value
    let tripDays = document.querySelector('.trip-days').value
    console.log(`${hasStart} ${hasEnd} ${tripDays}`)
    console.log("date check ok")
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
