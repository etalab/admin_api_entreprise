window.addEventListener('load', function() {
  init()

  function init() {
    const accordeons = document.getElementsByClassName('fr-accordion')

    if (accordeons.length == 0)
      return

    if (window.location.hash) {
      const hash = window.location.hash

      openDetails(hash)
    }
  }

  function openDetails(hash) {
    const target = document.getElementById(decodeURIComponent(hash.substring(1)))

    if (target) {
      const accordeon = target.querySelector('.fr-accordion__btn')

      setTimeout(function() {
        accordeon.setAttribute('aria-expanded', 'true');
        target.scrollIntoView()
      }, 100);
    }
  }
})
