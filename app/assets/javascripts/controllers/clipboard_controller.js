document.addEventListener("turbo:load", function () {
  window.Stimulus.register(
    "clipboard",
    class extends window.StimulusController {
      static targets = ["source"];

      copy() {
        this.sourceTarget.select();
        document.execCommand("copy");
      }
    }
  );
});
