Page = require 'page'
Plugin = require 'plugin'
Ui = require 'ui'
Dom = require 'dom'
Db = require 'db'

exports.renderSettings = !->
	if Db.shared
		Dom.text tr("Game has started")
	else
		selectMember
		name: 'opponent'
		title: tr("Opponent")

# This is the main entry point for a plugin:
exports.render = ->

	Dom.section !->
		Dom.style Box: 'middle'

		Dom.div !->
			Dom.style Flex: true
			Dom.h2 "Hi"
			Dom.text "Test"

		Ui.bigButton tr("Accept"), !->
			Server.call 'accept'

selectMember = (opts) !->
	opts ||= {}
	[handleChange, initValue] = Form.makeInput opts, (v) -> 0|v
	value = Obs.create(initValue)
	Form.box !->
		Dom.style fontSize: '125%', paddingRight: '56px'
		Dom.text opts.title||tr("Selected member")
		v = value.get()
		Dom.div !->
			Dom.style color: (if v then 'inherit' else '#aaa')
			Dom.text (if v then Plugin.userName(v) else tr("Nobody"))
			if v
				Ui.avatar Plugin.userAvatar(v), !->
					Dom.style position: 'absolute', right: '6px', top: '50%', marginTop: '-20px'
					Dom.onTap !->
						Modal.show opts.selectTitle||tr("Select member"), !->
							Dom.style width: '80%'
							Dom.div !->
								Dom.style
								maxHeight: '40%'
								overflow: 'auto'
								_overflowScrolling: 'touch'
								backgroundColor: '#eee'
								margin: '-12px'
								Plugin.users.iterate (user) !->
									Ui.item !->
										Ui.avatar user.get('avatar')
										Dom.text user.get('name')
										if +user.key() is +value.get()
											Dom.style fontWeight: 'bold'
											Dom.div !->
												Dom.style
												Flex: 1
												padding: '0 10px'
												textAlign: 'right'
												fontSize: '150%'
												color: Plugin.colors().highlight
												Dom.text "✓"
												Dom.onTap !->
													handleChange user.key()
													value.set user.key()
													Modal.remove()
													, (choice) !->
														log 'choice', choice
														if choice is 'clear'
															handleChange ''
															value.set ''
															, ['cancel', tr("Cancel"), 'clear', tr("Clear")]
