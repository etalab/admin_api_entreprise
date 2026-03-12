document.addEventListener("turbo:load", function () {
  window.Stimulus.register(
    "scopes-display",
    class extends window.StimulusController {
      static targets = ["select", "scopesList"];

      update() {
        const selectedOption =
          this.selectTarget.options[this.selectTarget.selectedIndex];
        this.scopesListTarget.textContent =
          selectedOption.dataset.scopes;
      }
    }
  );
});
