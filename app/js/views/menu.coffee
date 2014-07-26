class MenuView extends Backbone.Marionette.ItemView
    template: _.template("""
        <div class="row">
            <div class="col-xs-12">
            	<ul class="nav nav-pills">
					<li class="active"><a href="#" data-href="list"><i class="fa fa-home"></i> Home</a></li>
					<li><a href="#" data-href="torrentlist"><i class="fa fa-cloud-download"></i> Downloads</a></li>
				</ul>
			</div>
        </div>""")
    events:
    	"click .nav a": "navigate"
    ui:
    	tabs: ".nav li"
    navigate: (e) ->
    	$this = @$(e.currentTarget)
    	@ui.tabs.removeClass("active")
    	$this.parent().addClass "active"

    	App.vent.trigger("navigate:#{$this.attr('data-href')}")


exports.MenuView = MenuView