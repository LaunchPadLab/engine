Locomotive.Views.ContentEntries ||= {}

class Locomotive.Views.ContentEntries.EditView extends Locomotive.Views.ContentEntries.FormView

  save: (event) ->
    @save_in_ajax event,
      on_success: (response, xhr) =>
        @model.update_attributes(response)
        @refresh_file_fields()

$(window).bind "load", ->
  recurring_id = "#content_entry_recurring_input"
  is_recurring = $("li" + recurring_id + " input")
  weekdays_id = "#content_entry_weekdays_input"
  frequency_id = "#content_entry_frequency_id_input"
  stop_date_id = "#content_entry_formatted_stop_date_input"
  monthly_type_id = "#content_entry_monthly_type_id_input"
  weekday_id = "#content_entry_weekday_id_input"
  monthly_week_id = "#content_entry_monthly_week_id_input"

  recurring_fields = [weekdays_id, frequency_id, stop_date_id, monthly_type_id, weekday_id, monthly_week_id]
  monthly_fields = [monthly_type_id, weekday_id, monthly_week_id, stop_date_id]
  weekly_fields = [weekdays_id, stop_date_id]
  monthly_day_of_week_fields = [weekday_id, monthly_week_id]
  daily_fields = [stop_date_id]

  $recurring_fields = $(recurring_fields.join(", "))
  $monthly_fields = $(monthly_fields.join(", "))
  $weekly_fields = $(weekly_fields.join(", "))
  $monthly_day_of_week_fields = $(monthly_day_of_week_fields.join(", "))
  $daily_fields = $(daily_fields.join(", "))

  showWeeklyFields = () ->
    $monthly_fields.hide()
    $weekly_fields.show()

  showDailyFields = () ->
    $weekly_fields.hide()
    $monthly_fields.hide()
    $daily_fields.show()

  showBiweeklyFields = () ->
    showWeeklyFields()

  showMonthlyFields = () ->
    $weekly_fields.hide()
    $monthly_fields.show()
    monthly_type = $(monthly_type_id + " select").find(":selected").text()
    if monthly_type == "By day of week"
      $monthly_day_of_week_fields.show()
    else
      $monthly_day_of_week_fields.hide()

  showFields = () ->
    $recurring_fields.hide()
    $(frequency_id).show()

  showFrequencyFields = () ->
    frequency = $(frequency_id + " select").find(":selected").text()
    function_name = "show" + frequency + "Fields()"
    eval function_name


  # SET DEFAULT STATE (EDIT PAGE)
  if !is_recurring.is(":checked")
    $recurring_fields.hide()
  else
    showFrequencyFields()

  # RECURRING EVENT CHECKBOX HANDLER
  $("li" + recurring_id + " input").on "change", ->
    if $(this).is(":checked")
      console.log "checked"
      $recurring_fields.show()
      showFrequencyFields()
    else
      console.log "not checked"
      $recurring_fields.hide()
    return

  $(frequency_id + ", " + monthly_type_id).on "change", ->
    showFrequencyFields()

  $.each $recurring_fields, (index, el) ->
    $(el).addClass("has-parent")