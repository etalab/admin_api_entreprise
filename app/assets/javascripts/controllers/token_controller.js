document.addEventListener("turbo:load", function () {
  window.Stimulus.register(
    "token",
    class extends window.StimulusController {
      select(event) {
        let jwt_id = event.target.selectedOptions[0].value

        window.RequestJS.get(`/profile/attestations/new?jwt_id=${jwt_id}`, {
          responseKind: "turbo-stream"
        })
      }
    }
  );
});
