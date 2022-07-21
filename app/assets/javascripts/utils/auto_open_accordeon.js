['turbo:render', 'turbo:load'].forEach(function(e) {
  document.addEventListener(e, function() {
    initAutoOpenAccordeon()

    function initAutoOpenAccordeon() {
      const accordeons = document.getElementsByClassName('fr-accordion')

      if (accordeons.length == 0)
        return

      if (window.location.hash) {
        const hash = window.location.hash

        _openAccordeonDetails(hash)
      }
    }

    function _openAccordeonDetails(hash) {
      const target = document.getElementById(decodeURIComponent(hash.substring(1)))

      if (target) {
        const accordeon = target.querySelector('.fr-accordion__btn')

        if (accordeon) {
          setTimeout(function() {
            accordeon.setAttribute('aria-expanded', 'true');
          }, 100);

          setTimeout(function() {
            target.scrollIntoView()
          }, 300);
        }
      }
    }
  })
});
