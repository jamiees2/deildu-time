class HeaderView extends Backbone.Marionette.ItemView
    template: _.template("""
        <div class="row">
            <h1>
                <div class="col-xs-6"><h1>Deildu Time</h1></div>
            </h1>
        </div>""")


exports.HeaderView = HeaderView