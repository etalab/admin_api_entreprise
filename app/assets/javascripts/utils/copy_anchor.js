function copyAnchor(anchor) {
  const pageUrlNoAnchor = document.URL.replace(/#.*$/, "")
  const url = pageUrlNoAnchor + '#' + anchor

  navigator.clipboard.writeText(url)
}
