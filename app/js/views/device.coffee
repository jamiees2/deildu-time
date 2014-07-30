class DeviceView extends Backbone.Marionette.ItemView
    tagName: "li",
    template: _.template("""
        <a href='#'><%-name%></a>
        """)
    events: 
        "click a": "onClick"
    onClick: (e) ->
        e.preventDefault()
        App.vent.trigger('device:select',@model.toJSON())
        # @$el.addClass('success')

exports.DeviceView = DeviceView