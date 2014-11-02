Locomotive.Views.Pages ||= {}

class Locomotive.Views.Pages.EditView extends Locomotive.Views.Pages.FormView

  $(window).bind "load", ->

    $controls = $("body").find(".widget-type-control")
    $.each ($controls), (index, value) ->
      widget_index = $(value).data("widget-index")
      widget_type = $(value).val()
      $inputs_to_hide = $(".widget-index-" + widget_index)
      $.each ($inputs_to_hide), (index, value) ->
        $(value).parents("li").first().hide()
        return
      if widget_type.toLowerCase() != 'none'
        $input_to_show = $(".widget-index-" + widget_index + "." + "widget-type" + "-" + widget_type)
        $input_to_show.parents('li').show()
    $controls.parents('li').show();
    $controls.parents('li.block').hide();

  $ ->

    $("body").on "change", ".widget-type-control", (e) ->
      widget_index = $(this).data("widget-index")
      widget_type = $(this).val()
      $inputs_to_hide = $(".widget-index-" + widget_index)
      $.each ($inputs_to_hide), (index, value) ->
        $(value).parents("li").first().hide()
      $input_to_show = $(".widget-index-" + widget_index + "." + "widget-type" + "-" + widget_type)
      $input_to_show.parents('li').show()
      $("body").find(".widget-type-control").parents('li').show();
