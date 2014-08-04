class MenuView extends Backbone.Marionette.ItemView
    template: _.template("""
        <div class="row">
            <div class="col-xs-12">
                <ul class="nav nav-pills">
                    <li class="active"><a href="#" data-href="itemlist"><i class="fa fa-home"></i> Home</a></li>
                    <li><a href="#" data-href="torrentlist"><i class="fa fa-cloud-download"></i> Downloads</a></li>
                </ul>
            </div>
        </div>""")
    events:
        "click .nav a": "navigateEl"
    ui:
        tabs: ".nav li"
    initialize: ->
        @on 'navigate', @navigate
    navigateEl: (e) ->
        $this = @$(e.currentTarget)
        @navigate($this.attr('data-href'))
    navigate: (target) ->
        @ui.tabs.removeClass("active")
        @$("a[data-href=#{target}]").parent().addClass "active"

        # @trigger("navigate:#{}")
        App.container.content.show App.views[target], { preventDestroy: true }




    


exports.MenuView = MenuView