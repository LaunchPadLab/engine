$(function(){

  $('form.public_resource_form #public_resource_type').on('change', function(){
    var val = $(this).val();

    var $field_areas = $(".public_resource_field_area").hide();
    $field_areas.find("input").attr("disabled", "disabled");

    var $field_area_to_show = $("#public_resource_" + val + "_area");
    $field_area_to_show.find("input").removeAttr("disabled");
    $field_area_to_show.show();
  });

});