
function addTooltip(id, text) {
  const tooltip = document.getElementById('tooltip');
  const target = document.getElementById(id);

  changeTextTooltip(text)

  const popperInstance = Popper.createPopper(target, tooltip, {
    placement: 'top',
  });

  tooltip.setAttribute('data-show', '');
  popperInstance.update();

  addHideEventsTooltip(target);
}

function changeTextTooltip(text) {
  const tooltipText = document.getElementById('tooltip-text');
  tooltipText.textContent = text;
}

function addHideEventsTooltip(target) {
  const hideEvents = ['mouseleave', 'blur'];

  hideEvents.forEach((event) => {
    target.addEventListener(event, function() { hideTooltip(tooltip) });
  });
}

function hideTooltip(tooltip) {
  tooltip.removeAttribute('data-show');
}

