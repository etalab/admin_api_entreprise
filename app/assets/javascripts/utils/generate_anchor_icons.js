window.addEventListener('load', function() {
  init()

  function init() {
    const bigTitles = document.querySelectorAll("h1, h2, h3, section")

    bigTitles.forEach(addAnchorCopyButton)
  }

  function addAnchorCopyButton(title) {
    if (!title || !title.id)
      return

    const anchorCopyButton = buildAnchorCopyButton(title.id)

    title.prepend(anchorCopyButton)
  }

  function buildAnchorCopyButton(id) {
    const anchorCopyButton = document.createElement('span');
    const copyFunctionString = `copyAnchor("${id}");`

    anchorCopyButton.classList.add('fr-icon-links-line', 'fr-copy-anchor-btn');
    anchorCopyButton.setAttribute('aria-hidden', 'true');

    anchorCopyButton.setAttribute("onclick", copyFunctionString);

    return anchorCopyButton;
  }
})

function copyAnchor(anchor) {
  const pageURLNoAnchor = document.URL.replace(/#.*$/, "")
  const pageURLWithAnchor = pageURLNoAnchor + '#' + anchor

  navigator.clipboard.writeText(pageURLWithAnchor)
}
