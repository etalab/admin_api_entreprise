
function addTooltip(id, text) {
  const tooltip = document.getElementById('tooltip');
  const target = document.getElementById(id);

  changeText(text)

  const popperInstance = Popper.createPopper(target, tooltip, {
    placement: 'top',
  });

  tooltip.setAttribute('data-show', '');
  popperInstance.update();

  addHideEvents(target);
}

function changeText(text) {
  const tooltipText = document.getElementById('tooltip-text');
  tooltipText.textContent = text;
}

function addHideEvents(target) {
  const hideEvents = ['mouseleave', 'blur'];

  hideEvents.forEach((event) => {
    target.addEventListener(event, function() { hide(tooltip) });
  });
}

function hide(tooltip) {
  tooltip.removeAttribute('data-show');
}

