import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="collapsible-sections"
export default class extends Controller {
  connect() {
    console.log("collapsible controller");
  }

  static targets = ['section']

  toggleCollapse (event) {
    console.log(this.sectionTarget)
    this.icon = this.sectionTarget.querySelector("i")
    this.header = this.sectionTarget.querySelector(".card-header")
    this.body = this.sectionTarget.querySelector(".collapse")
    this.collapsed = this.icon.classList.contains("fa-plus")

    this.collapsed ? this.#openSection() : this.#closeSection()
  }

  #openSection () {
    this.sectionTarget.classList.add("h-100")
    this.icon.classList.add("fa-minus")
    this.icon.classList.remove("fa-plus")
    this.header.classList.remove("rounded", "bg-secondary")
    this.header.classList.add("bg-success")
    this.body.classList.add("show")
  }

  #closeSection () {
    this.sectionTarget.classList.remove("h-100")
    this.icon.classList.remove("fa-minus")
    this.icon.classList.add("fa-plus")
    this.header.classList.add("rounded","bg-secondary")
    this.header.classList.remove("bg-success")
    this.body.classList.remove("show")
  }
}
