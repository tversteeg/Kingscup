Page = require 'page'
Plugin = require 'plugin'
Ui = require 'ui'
Dom = require 'dom'

# This is the main entry point for a plugin:
exports.render = ->
	Dom.section !->
		Dom.style Box: 'middle'

		Dom.div !->
			Dom.style Flex: true
			Dom.h2 "Hi"
			Dom.text "Test"

			Plugin.users.iterate (user) !->
				Ui.item !->
					Ui.avatar user.get('avatar')
					Dom.text user.get('name')
