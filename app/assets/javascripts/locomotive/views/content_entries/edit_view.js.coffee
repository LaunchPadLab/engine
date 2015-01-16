Locomotive.Views.ContentEntries ||= {}

class Locomotive.Views.ContentEntries.EditView extends Locomotive.Views.ContentEntries.FormView

  save: (event) ->
    @save_in_ajax event,
      on_success: (response, xhr) =>
        @model.update_attributes(response)
        @refresh_file_fields()

$(window).bind "load", ->
  is_recurring = $("li#content_entry_recurring_input input")

  if !is_recurring.is(":checked")
    $("#content_entry_weekdays_input").hide()
    $("#content_entry_frequency_input").hide()
    $("#content_entry_formatted_stop_date_input").hide()

  $("li#content_entry_recurring_input input").on "change", ->
    if $(this).is(":checked")
      $("#content_entry_weekdays_input").show()
      $("#content_entry_frequency_input").show()
      $("#content_entry_formatted_stop_date_input").show()
    else
      $("#content_entry_weekdays_input").hide()
      $("#content_entry_frequency_input").hide()
      $("#content_entry_formatted_stop_date_input").hide()
    return