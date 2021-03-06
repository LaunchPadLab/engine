Locomotive.Views.EditableElements ||= {}

class Locomotive.Views.EditableElements.ControlView extends Backbone.View

  tagName: 'li'

  className: 'control input'

  render: ->
    $(@el).html(ich.editable_control_input(@model.toJSON()))

    @bind_model()

    return @

  after_render: ->
    if @model.get('widget_type') == 'Album'
      name = @$('textarea').attr('name')
      CKEDITOR.replace(name)

  refresh: ->
    @bind_model()

  bind_model: ->
    Backbone.ModelBinding.bind @, { select: 'id' }

