document.addEventListener("turbo:load", function () {
  window.Stimulus.register(
    "datetime-now",
    class extends window.StimulusController {
      static targets = ["input"];

      setNow() {
        const now = new Date();
        const year = now.getFullYear();
        const month = String(now.getMonth() + 1).padStart(2, "0");
        const day = String(now.getDate()).padStart(2, "0");
        const hours = String(now.getHours()).padStart(2, "0");
        const minutes = String(now.getMinutes()).padStart(2, "0");

        this.inputTarget.value = `${year}-${month}-${day}T${hours}:${minutes}`;
      }
    }
  );
});
