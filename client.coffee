Page = require 'page'
Plugin = require 'plugin'
Ui = require 'ui'
Dom = require 'dom'
Obs = require 'obs'
Db = require 'db'

# This is the main entry point for a plugin:
exports.render = ->
	#if Plugin.users.count().get() < 2
	#	Ui.emptyText "You need at least 2 members in your happening group to play Kingscup"
	#	return

	value = Obs.create(0)

	Dom.section !->
		Dom.style Box: 'middle'

		Dom.div !->
			Dom.style Flex: true
			Dom.h2 "Select players:"

			Plugin.users.iterate (user) !->
				Ui.item !->
					Ui.avatar user.get('avatar')
					Dom.text user.get('name')

					if +user.key() is +value.get()
						Dom.div !->
							Dom.style	color: Plugin.colors().highlight
							Dom.text "✓"

					Dom.onTap !->
						value.set user.key()
