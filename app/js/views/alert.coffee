class AlertView extends Backbone.Marionette.ItemView
    template: _.template("""
        <div class="alert alert-danger" role="alert">
            <%= error %>
            <a href="#" id="retry"><strong>Retry</strong></a>
        </div>""")
    events:
        "click #retry": "retry"
    retry: (e) ->
        e.preventDefault()
        @trigger('retry')


exports.AlertView = AlertView