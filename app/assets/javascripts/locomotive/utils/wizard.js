/*******************************************************************************************************/
/*******************************************************************************************************/
var Wizard = (function () {
  'use strict';

  var WizardViews = function () {

    var Node = function (view) {
      var _next = null; //reference next node
      var _previous = null; //reference previus node
      var _view = view.ref; //referce current view
      var _tab = view.tab;
      var _namespace = view.namespace;
      var _validator = view.ref.validator;
      return {
        setPrevious: function (node) { _previous = node; return this; }, //chainable!
        getPrevious: function () { return _previous; },
        setNext: function (node) { _next = node; return this; }, //chainable!
        getNext: function () { return _next; },
        getView: function () { return _view; },
        getTab: function () { return _tab; },
        validate: function () {
          _errors = (typeof(_validator)==='undefined' ? {} : _validator());
          return _errors;
        },
        clear_errors: function(){
          $('.inline-errors').remove();
        },
        show_errors: function(errors) {
          var attribute, html, message, _results;
          _results = [];
          this.clear_errors();
          for (attribute in errors) {
            message = errors[attribute];
            if (_.isString(message[0])) {
              html = $("<div class=\"inline-errors\"><p>" + message[0] + "</p></div>");
              _results.push(this.show_error(attribute, message[0], html));
            } else {
              _results.push(this.show_error(attribute, message));
            }
          }
          return _results;
        },
        show_error: function(attribute, message, html) {
          var anchor, input, prefix;
          prefix = this._namespace != null ? "" + this._namespace + "_" : '';
          input = $("#" + prefix + attribute);
          if (input.size() === 0) {
            input = $("#" + prefix  + attribute + "_id");
          }
          if (input.size() === 0) {
            input = $("#" + prefix + attribute + "_ids");
          }
          if (!(input.size() > 0)) {
            return;
          }
          anchor = input.parent().find('.error-anchor');
          if (anchor.size() === 0) {
            anchor = input;
          }
          return anchor.after(html);
        }
      };
    };

    var _head    = null;
    var _tail    = null;
    var _current = null;
    var _errors  = {};
    return {
      first: function () { return _head; },
      last: function () { return _tail; },
      moveNext: function () {
        return (_current !== null) ? _current = _current.getNext() : null;
      }, //set current to next and return current or return null
      movePrevious: function () {
        return (_current !== null) ? _current = _current.getPrevious() : null;
      }, //set current to previous and return current or return null
      getCurrent: function () { return _current; },
      insertView: function (view) {
        if (_tail === null) { // list is empty (implied head is null)
          _current = _tail = _head = new Node(view);
        }
        else {//list has nodes
          _tail = _tail.setNext(new Node(view).setPrevious(_tail)).getNext();
        }
      },
      setCurrentByTab: function (tab) {
        var node = _head;
        while (node !== null) {
          if (node.getTab() !== tab) { node = node.getNext(); }
          else { _current = node; break; }

        }
      },
      errors: function(){
        return _errors;
      },
      validateCurrentView: function() {
        return _current.validate();
      },
      validateViews: function(){
        var errors={};
        var node = _head;
        while (node !== null) {
          var error = node.validate();
          if (error) { for (var attr in error) { errors[attr] = error[attr]; } }
          node = node.getNext();
        }
        _errors = errors;
        if ($.isEmptyObject(errors) == false){
          $.growl("error", "There are errors on this form. Please check each tab.");
        }
        _current.show_errors(errors);
        return errors;
      }
    };
  };

  var WizardView = Backbone.View.extend({
    tagName: 'div',
    initialize: function () {
      _.bindAll(this, 'render', 'movePrevious', 'moveNext', 'insertView', 'save', 'moveToTab');
      $(this.el).append($($("#wizard-template").html()));
      this.wizardViewTabs = $(this.el).find('#wizard-view-tabs');
      this.wizardViewContainer = $(this.el).find('#wizard-view-container');
      this.wizardViews = new WizardViews();

    },
    events: {
      "click .btn-previousView": "movePrevious",
      "click .btn-nextView": "moveNext",
      "click .btn-save": "save",
      "click .nav-tabs a": "moveToTab"
    },

    render: function () {
      var currentView = this.wizardViews.getCurrent();
      if (currentView !== null) {

        if (currentView.getNext() === null) {
          $('.btn-nextView', this.el).hide();
          $('.form-actions', this.el).show();
        } else {
          $('.btn-nextView', this.el).show();
          $('.form-actions', this.el).hide();
        }
        if (currentView.getPrevious() === null) {
          $('.btn-back', this.el).show();
          $('.btn-previousView', this.el).hide();
        } else {
          $('.btn-back', this.el).hide();
          $('.btn-previousView', this.el).show();
        }

        //clear the active tab css class
        this.wizardViewTabs.
          find('li').removeClass('on');

        //set the active tab for the current view
        this.wizardViewTabs.
          find('a[title=' + currentView.getTab() + ']').
          parents('li:first').addClass('on');

        //show only the current view
        this.wizardViewContainer.find('.wizard-view:parent').hide();
        $(currentView.getView().render().el).show();

        //show current errors
        console.log(this.wizardViews.errors());
        currentView.show_errors(this.wizardViews.errors());

      }
      return this;
    },
    insertView: function (view) {

      var tab = view.tab;
      view.tab = view.tab.replace(/\s/g, '-');

      this.wizardViewTabs.
        append('<li class="entry"><div class="left"><span></span></div><a href="#' + view.tab + '" title="' + view.tab + '"><span>' + tab + '</span></a><div class="right"><span></span></div></li>');

      this.wizardViewContainer.append($(view.ref.render().el).hide());
      this.wizardViews.insertView(view);
    },
    movePrevious: function () {
      this.updateModel();
      this.wizardViews.movePrevious();
      this.render();
      return false;
    },

    moveNext: function () {
      this.updateModel();
      this.wizardViews.moveNext();
      this.render();
      return false;
    },
    moveToTab: function (e) {
      e = e || window.event;
      var anchor = $(e.currentTarget || e.target);
      this.updateModel();
      this.wizardViews.setCurrentByTab($(anchor).attr('title'));
      this.render();
      return false;
    },
    updateModel: function () {
      this.wizardViews.getCurrent().getView().updateModel();
    },
    validate: function() {
      // check required fields for presence
      return this.wizardViews.validateViews();
    },
    save: function () {
      this.updateModel();
      // validate fields
    }
  });

  var _wizardView = null;

  return {
    initialize: function(wizardModel){
      _wizardView = new WizardView({model:wizardModel});
    },
    insertView: function (view) {
      _wizardView.insertView(view);
    },
    render: function () {
      return _wizardView.render();
    },
    validate: function (){
      return _wizardView.validate();
    }
  };

})();

