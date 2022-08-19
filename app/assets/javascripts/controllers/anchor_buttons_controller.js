function copyAnchor(self) {
  const pageURLNoAnchor = document.URL.replace(/\?.*$/, "").replace(/#.*$/, "")
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

      addAnchorCopyButton(title, controller) {
        if (!title || !title.id || controller._anchorExist(title.id))
          return

        const anchorCopyButton = this._buildAnchorCopyButton(title.id);

        title.prepend(anchorCopyButton)
      };

      // private

      _anchorExist(id) {
        return document.getElementById(`button-anchor-${id}`) != null;
      }

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

