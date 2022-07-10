function copyAnchor(anchor) {
  const pageURLNoAnchor = document.URL.replace(/#.*$/, "")
  const pageURLWithAnchor = pageURLNoAnchor + '#' + anchor

  navigator.clipboard.writeText(pageURLWithAnchor)
}

document.addEventListener("turbo:load", function () {
  window.Stimulus.register(
    "anchor-buttons",
    class extends window.StimulusController {

      connect() {
        const bigTitles = document.querySelectorAll("h1, h2, h3, section")
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
        const copyFunctionString = `copyAnchor("${id}");`

        anchorCopyButton.classList.add('fr-icon-links-line', 'fr-copy-anchor-btn');
        anchorCopyButton.setAttribute('aria-hidden', 'true');

        anchorCopyButton.setAttribute("onclick", copyFunctionString);

        return anchorCopyButton;
      };
    }
  )
});

