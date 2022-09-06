import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="collapsible-sections"
export default class extends Controller {
  connect() {

  }

  static targets = ['section', 'button']
  static values = { open: String, closed: String, textOpen: String, textClosed: String }

  toggleCollapse (event) {
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

    this.header.classList.remove("rounded", this.closedValue||'bg-secondary')
    this.header.classList.add(this.openValue||'bg-success')

    this.buttonTarget.classList.remove(this.textClosedValue||'text-white')
    this.buttonTarget.classList.add(this.textOpenValue||'text-white')

    this.body.classList.add("show")
  }

  #closeSection () {
    this.sectionTarget.classList.remove("h-100")
    this.icon.classList.remove("fa-minus")
    this.icon.classList.add("fa-plus")

    this.header.classList.remove(this.openValue||'bg-success')
    this.header.classList.add("rounded",this.closedValue||'bg-secondary')

    this.buttonTarget.classList.remove(this.textOpenValue||'text-white')
    this.buttonTarget.classList.add(this.textClosedValue||'text-white')

    this.body.classList.remove("show")
  }
}
