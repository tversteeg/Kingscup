Page = require 'page'
Form = require 'form'
Plugin = require 'plugin'
Ui = require 'ui'
Dom = require 'dom'
Obs = require 'obs'
Db = require 'db'
Server = require 'server'

# This is the main entry point for a plugin:
exports.render = ->
	#if Plugin.users.count().get() < 2
	#	Ui.emptyText "You need at least 2 members in your happening group to play Kingscup"
	#	return
	userId = Plugin.userId()
	players = Db.shared.peek('players')

	Ui.button "Increment", !->
		Server.call "addUser", userId

	Dom.div !->
		Dom.style
			display: 'inline-block'
			width: '80%'
			height: '80%'
			background: "url(#{Plugin.resourceUri('2_of_clubs.png')}) 100% 100% no-repeat"
			backgroundSize: 'contain'

exports.getTitle = !->
	"Kingscup!"

exports.renderSettings = !->
	if Db.shared
		Dom.text "Game has started"
	else
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
