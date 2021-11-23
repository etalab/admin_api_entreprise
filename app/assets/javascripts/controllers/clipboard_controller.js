document.addEventListener("turbo:load", function () {
  window.Stimulus.register(
    "clipboard",
    class extends window.StimulusController {
      static targets = ["source"];
      static values = {
        alertMessage: String,
      };

      copy() {
        this.sourceTarget.select();
        document.execCommand("copy");

        if (this.hasAlertMessageValue) {
          alert(this.alertMessageValue);
        }
      }
    }
  );
});
