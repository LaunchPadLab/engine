// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery-ui
//= require jquery_ujs
//= require jquery.simplePagination
//= require underscore
//= require backbone
//= require codemirror
//= require tinymce-jquery
//= require ckeditor/init

//= require moment.min.js
//= require jquery.visible.min.js
//= require calendar
//= require events
//= require lyris
//= require portal_resources
//= require select2/select2
//= require codemirror/addons/mode/overlay
//= require codemirror/modes/css
//= require codemirror/modes/javascript
//= require codemirror/modes/xml
//= require codemirror/modes/htmlmixed
//= require locomotive/vendor
//= require ./locomotive/application

$(document).ready(function() {
  $.datepicker.setDefaults($.datepicker.regional[window.locale]);
});
