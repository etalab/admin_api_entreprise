window.addEventListener('load', function() {
  init()

  function init() {
    if (window.location.hash) {
      const hash = window.location.hash

      openDetails(hash)
    }
  }

  function openDetails(hash) {
    const target = document.getElementById(decodeURIComponent(hash.substring(1)))

    if (target) {
      const accordeon = target.querySelector('.fr-accordion__btn')

      accordeon.setAttribute('aria-expanded', 'true');

      setTimeout(function() {
        target.scrollIntoView()
      }, 100);
    }
  }
})
