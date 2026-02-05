document.addEventListener("turbo:load", function () {
  window.Stimulus.register(
    "array-field",
    class extends window.StimulusController {
      static targets = ["container", "template"];

      add(event) {
        event.preventDefault();
        const content = this.templateTarget.innerHTML;
        this.containerTarget.insertAdjacentHTML("beforeend", content);
      }

      remove(event) {
        event.preventDefault();
        const field = event.target.closest("[data-array-field-item]");
        if (field && this.containerTarget.querySelectorAll("[data-array-field-item]").length > 1) {
          field.remove();
        }
      }
    }
  );
});
