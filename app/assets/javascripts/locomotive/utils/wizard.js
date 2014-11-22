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
            return {
                setPrevious: function (node) { _previous = node; return this; }, //chainable!
                getPrevious: function () { return _previous; },
                setNext: function (node) { _next = node; return this; }, //chainable!
                getNext: function () { return _next; },
                getView: function () { return _view; },
                getTab: function () { return _tab; }
            };
        };

        var _head = null;
        var _tail = null;
        var _current = null;

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
                    $('.btn-previousView', this.el).hide();
                } else {
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
            var anchor = $(e.srcElement || e.target);
            this.updateModel();
            this.wizardViews.setCurrentByTab($(anchor).attr('title'));
            this.render();
                        return false;
        },
        updateModel: function () {
            this.wizardViews.getCurrent().getView().updateModel();
            //favor view update method convention to force synchronous updates
        },
        save: function () {
            this.updateModel();
            // alert(JSON.stringify(this.model.toJSON()));
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
        }
    };

})();

