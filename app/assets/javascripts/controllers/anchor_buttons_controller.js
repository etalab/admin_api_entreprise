function copyAnchor(self) {
  const pageURLNoAnchor = document.URL.replace(/#.*$/, "")
  const pageURLWithAnchor = pageURLNoAnchor + '#' + self.id.replace('button-anchor-', '')

  navigator.clipboard.writeText(pageURLWithAnchor)
    .then(addTooltip(self.id, 'Lien copié !'));
}

document.addEventListener("turbo:load", function () {
  window.Stimulus.register(
    "anchor-buttons",
    class extends window.StimulusController {
      static values = {
        tags: Array
      }

      initialize() {
        const bigTitles = document.querySelectorAll(this.tagsValue)
        let controller = this

        bigTitles.forEach(function(title) {
          controller.addAnchorCopyButton(title, controller);
        })
      };

      addAnchorCopyButton(title) {
        if (!title || !title.id)
          return

        const anchorCopyButton = this._buildAnchorCopyButton(title.id);

        title.prepend(anchorCopyButton)
      };

      // private

      _buildAnchorCopyButton(id) {
        const anchorCopyButton = document.createElement('span');

        anchorCopyButton.classList.add('fr-icon-links-line', 'fr-copy-anchor-btn');
        anchorCopyButton.setAttribute('id', `button-anchor-${id}`)
        anchorCopyButton.setAttribute('aria-hidden', 'true');

        const copyFunctionString = `copyAnchor(this);`
        anchorCopyButton.setAttribute("onclick", copyFunctionString);

        return anchorCopyButton;
      };
    }
  )
});

