module DsfrStepperHelper
  def dsfr_stepper(current_step:, steps:)
    content_tag(:div, class: 'fr-stepper') do
      [
        dsfr_stepper_title(current_step),
        dsfr_stepper_steps(current_step, steps),
        dsfr_stepper_details(current_step, steps)
      ].join(' ').html_safe
    end
  end

  private

  def dsfr_stepper_title(current_step)
    content_tag(:h2, class: 'fr-stepper__title') do
      [
        current_step
      ].join(' ').html_safe
    end
  end

  def dsfr_stepper_steps(current_step, steps)
    content_tag(
      :div,
      '',
      class: 'fr-stepper__steps',
      data: {
        'fr-current-step': stepper_step_number(current_step, steps),
        'fr-steps': steps.size
      }
    ).html_safe
  end

  def dsfr_stepper_details(current_step, steps)
    return '' if stepper_next_step(current_step, steps).nil?

    content_tag(:p, class: 'fr-stepper__details') do
      [
        content_tag(:span, I18n.t('shared.wizard.next_step'), class: 'fr-text--bold'),
        stepper_next_step(current_step, steps)
      ].join(' ').html_safe
    end
  end

  def stepper_step_number(current_step, steps)
    steps.index(current_step) + 1
  end

  def stepper_next_step(current_step, steps)
    return if current_step == steps.last

    steps[stepper_step_number(current_step, steps)]
  end

  def prolong_token_wizard_step_name(step)
    I18n.t("shared.prolong_token_wizard.steps.#{step}")
  end
end
