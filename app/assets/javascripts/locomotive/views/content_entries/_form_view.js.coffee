#= require ../shared/form_view

Locomotive.Views.ContentEntries ||= {}

class Locomotive.Views.ContentEntries.FormView extends Locomotive.Views.Shared.FormView

  el: '#content'

  _select_field_view: null

  _file_field_views: []

  _belongs_to_field_views: []

  _has_many_field_views: []

  _many_to_many_field_views: []

  all_day_id = "#content_entry_all_day_input"
  start_date_id = "#content_entry_formatted_start_date_input"
  end_date_id = "#content_entry_formatted_end_date_input"
  start_time_id = "#content_entry_formatted_start_time_input"
  end_time_id = "#content_entry_formatted_end_time_input"

  all_day_fields = [start_date_id, end_date_id]
  time_fields = [start_time_id, end_time_id]

  events:
    'submit': 'customSave'
    'change #content_entry_all_day_input input': 'update_all_day'

  initialize: ->
    @content_type ||= new Locomotive.Models.ContentType(@options.content_type)

    @model ||= new Locomotive.Models.ContentEntry(@options.content_entry)

    @namespace = @options.namespace

    Backbone.ModelBinding.bind @

  render: ->
    super()

    @enable_checkboxes()

    @enable_tags()

    @enable_datepickers()

    @enable_datetimepickers()

    @enable_richtexteditor()

    @enable_select_fields()

    @enable_belongs_to_fields()

    @enable_file_fields()

    @enable_has_many_fields()

    @enable_many_to_many_fields()

    @slugify_label_field()

    @set_all_day()

    @setup_image_repository_inputs()

    return @

  enable_checkboxes: ->
    @$('li.input.toggle input[type=checkbox]').checkToggle()

  enable_tags: ->
    @$('li.input.tags input[type=text]').tagit(allowSpaces: true)

  enable_datepickers: ->
    @$('li.input.date input[type=text]').datepicker()

  enable_datetimepickers: ->
    @$('li.input.date-time input[type=text]').datetimepicker
      controlType: 'select'
      showTime: false

  enable_richtexteditor: ->
    model = @model
    _.each @$('li.input.rte textarea.html'), (textarea) =>
      name = $(textarea).attr('name')
      editor = CKEDITOR.replace(name)
      # The "change" event is fired whenever a change is made in the editor.
      editor.on "change", (evt) ->
        data = evt.editor.getData()
        parsed_name = name.substr(14)
        parsed_name = parsed_name.substr(0, parsed_name.length - 1);
        model.set(parsed_name, data)


  enable_select_fields: ->
    @_select_field_view = new Locomotive.Views.Shared.Fields.SelectView model: @content_type

    _.each @model.get('select_custom_fields'), (name) =>
      $input_wrapper = @$("##{@model.paramRoot}_#{name}_id_input")

      $input_wrapper.append(ich.edit_select_options_button())

      $input_wrapper.find('a.edit-options-button').bind 'click', (event) =>
        event.stopPropagation() & event.preventDefault()

        @_select_field_view.render_for name, (options) =>
          # refresh the options of the select box
          $select = $input_wrapper.find('select')
          $select.find('option[value!=""]').remove()

          _.each options, (option) =>
            unless option.destroyed()
              $select.append(new Option(option.get('name'), option.get('id'), false, option.get('id') == @model.get("#{name}_id")))

  enable_belongs_to_fields: ->
    prefix = if @namespace? then "#{@namespace}_" else ''

    _.each @model.get('belongs_to_custom_fields'), (name) =>
      $el = @$("##{prefix}#{@model.paramRoot}_#{name}_id")

      if $el.length > 0
        view = new Locomotive.Views.Shared.Fields.BelongsToView model: @model, name: name, el: $el

        @_belongs_to_field_views.push(view)

        view.render()

  enable_file_fields: ->
    prefix = if @namespace? then "#{@namespace}_" else ''

    _.each @model.get('file_custom_fields'), (name) =>
      view = new Locomotive.Views.Shared.Fields.FileView model: @model, name: name, namespace: @namespace

      @_file_field_views.push(view)

      @$("##{prefix}#{@model.paramRoot}_#{name}_input label").after(view.render().el)

  enable_has_many_fields: ->
    unless @model.isNew()
      _.each @model.get('has_many_custom_fields'), (field) =>
        name = field[0]; inverse_of = field[1]
        new_entry = new Locomotive.Models.ContentEntry(@options["#{name}_new_entry"])
        view      = new Locomotive.Views.Shared.Fields.HasManyView model: @model, name: name, new_entry: new_entry, inverse_of: inverse_of

        if view.ui_enabled()
          @_has_many_field_views.push(view)

          @$("##{@model.paramRoot}_#{name}_input label").after(view.render().el)

  enable_many_to_many_fields: ->
    _.each @model.get('many_to_many_custom_fields'), (field) =>
      name = field[0]
      view = new Locomotive.Views.Shared.Fields.ManyToManyView model: @model, name: name, all_entries: @options["all_#{name}_entries"]

      if view.ui_enabled()
        @_many_to_many_field_views.push(view)

        @$("##{@model.paramRoot}_#{name}_input label").after(view.render().el)

  slugify_label_field: ->
    @$('li.input.highlighted > input[type=text]').slugify
      target: @$('#content_entry__slug')
      url:    window.permalink_service_url

  refresh_file_fields: ->
    _.each @_file_field_views, (view) => view.refresh()

  refresh: ->
    @$('li.input.toggle input[type=checkbox]').checkToggle('sync')
    @refresh_file_fields()

  reset: ->
    @$('li.input.string input[type=text], li.input.text textarea, li.input.date input[type=text]').val('').trigger('change')
    _.each @$('li.input.rte textarea.html'), (textarea) => $(textarea).tinymce().setContent(''); $(textarea).trigger('change')
    _.each @_file_field_views, (view) => view.reset()
    @$('li.input.toggle input[type=checkbox]').checkToggle('sync')

  remove: ->
    @$('li.input.date input[type=text]').datepicker('destroy')
    @$('li.input.date_time input[type=text]').datetimepicker('destroy')
    @_select_field_view.remove()
    _.each @_file_field_views, (view) => view.remove()
    _.each @_has_many_field_views, (view) => view.remove()
    _.each @_many_to_many_field_views, (view) => view.remove()
    super

  tinyMCE_settings: ->
    window.Locomotive.tinyMCE.defaultSettings

  start_time: ->
    $(start_time_id)

  end_time: ->
    $(end_time_id)

  start_date: ->
    $(start_date_id)

  end_date: ->
    $(end_date_id)

  all_day: ->
    $("li" + all_day_id)

  is_all_day: ->
    $("li" + all_day_id + " input")

  all_day_fields: ->
    $(all_day_fields.join(", "))

  time_fields: ->
    $(time_fields.join(", "))

  is_valid_date: (d) ->
    if Object::toString.call(d) != '[object Date]'
      return false
    !isNaN(d.getTime())

  get_date: ($field) ->
    $input = $field.find("input")
    date_string = $input.val()
    date = new Date(Date.parse(date_string))
    return date

  get_name: ($input) ->
    name = $input.attr('name')
    parsed_name = name.substr(14)
    parsed_name = parsed_name.substr(0, parsed_name.length - 1);

  to_parsed_date: (date) ->
    # m_names = new Array('January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December')
    curr_date = date.getDate()
    curr_month = date.getMonth() + 1
    curr_year = date.getFullYear()
    if (curr_month < 10)
      curr_month = "0" + curr_month
    if (curr_date < 10)
        curr_date = "0" + curr_date
    return curr_month + '/' + curr_date + '/' + curr_year

  paste_date: (date, $field, to_time) ->
    date_string = @to_parsed_date(date)
    $input = $field.find("input")
    if to_time
      date_string = date_string + " 00:00"
      $input.datetimepicker("setDate", date_string)
    else
      $input.datepicker("setDate", date_string)
    name = @get_name($input)
    @model.set(name, date_string)

  copy_date: ($from_date, $to_date, to_time) ->
    date = @get_date($from_date)
    if @is_valid_date(date)
      @paste_date(date, $to_date, to_time)

  copy_start_time_date: ->
    @copy_date(@start_time(), @start_date(), false)

  copy_end_time_date: ->
    @copy_date(@end_time(), @end_date(), false)

  copy_start_date: ->
    @copy_date(@start_date(), @start_time(), true)

  copy_end_date: ->
    @copy_date(@end_date(), @end_time(), true)

  copy_dates_from_times: ->
    @copy_start_time_date()
    @copy_end_time_date()

  copy_dates: ->
    @copy_start_date()
    @copy_end_date()

  show_date_fields: ->
    @all_day_fields().show()
    @time_fields().hide()

  show_time_fields: ->
    @all_day_fields().hide()
    @time_fields().show()

  all_day_checked: ->
    @copy_dates_from_times()
    @show_date_fields()

  all_day_not_checked: ->
    @copy_dates()
    @show_time_fields()

  update_all_day: ->
    if @is_all_day().is(":checked")
      @all_day_checked()
    else
      @all_day_not_checked()

  set_all_day: ->
    if @is_all_day().is(":checked")
      @show_date_fields()
    else
      @show_time_fields()
      start_time = @get_date(@start_time())
      start_minute = start_time.getHours()
      start_hour = start_time.getMinutes()
      end_time = @get_date(@end_time())
      end_hour = end_time.getHours()
      end_minute = end_time.getMinutes()
      sum_start = (start_hour + start_minute)
      sum_end = (end_hour + end_minute)
      if (sum_start == 0 && (sum_end == 0 || sum_end == (23 + 59)))
        @all_day().find(".switchHandle").trigger("click")

  setup_image_repository_inputs: ->
    $(".image-repository").each () ->
      $input = $(this).find("input")
      input_name = $input.attr("name")
      CKEDITOR.replace(input_name)
      CKEDITOR.on('instanceReady', ->
        $(".cke").hide()
      )

      field_id = $(this).attr("id")
      name = field_id.replace("_input", "").replace("content_entry_", "")
      ckeditor_id = "content_entry_#{name}"
      ckeditor_url = "/ckeditor/folders?CKEditor=#{ckeditor_id}&content_entry_field_id=#{field_id}&CKEditorFuncNum=1&langCode=en"

      value = $input.val()

      if value.length > 0
        path_parts = value.split("/")
        filename = path_parts[path_parts.length - 1]
      else
        filename = ""
        display_filename = "display:none;"

      $(this).append(
        "<p><a class='change' href='#{ckeditor_url}' target='_blank'>Choose Image From Repository</a><span #{display_filename} class='image-filename-area'>    (Currently Selected Image: <a class='image-filename' href='#{value}' target='_blank'>" + filename + "</a>)</span></p>")
      $(this).append("<p></p>")


  customSave: (event) ->
    that = @
    $(".image-repository").each () ->
      $input = $(this).find("input")
      name = that.get_name($input)
      that.model.set(name, $input.val())
    @save(event)