class DevicesView extends Backbone.Marionette.CompositeView
	childViewContainer: "ul"
	childView: require('./device').DeviceView
	template: _.template("""
		<strong>Play To</strong>
		<ul></ul>
		""")
exports.DevicesView = DevicesView