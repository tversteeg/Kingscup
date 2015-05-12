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

	playercount = Obs.create(if Db.shared then Db.shared.get 'settings', 'playercount' else 0)

	if Db.shared.get 'settings'
		Dom.text "Players:"
		Dom.text playercount.get()

exports.getTitle = !->
	"Kingscup!"

exports.renderSettings = !->
	if Db.shared
		Dom.text "Game has started"
	else
		playercount = Obs.create(0)
		players = Obs.create()

		Dom.section !->
			Dom.style Box: 'middle'

			Dom.div !->
				Dom.style Flex: true
				Dom.h2 "Select players:"

				Plugin.users.iterate (user) !->
					Ui.item !->
						Ui.avatar user.get('avatar')
						Dom.text user.get('name')

#						if +user.key() is +players.get()
#							Dom.div !->
#								Dom.style	color: Plugin.colors().highlight
#								Dom.text "✓"

						Dom.onTap !->
							players.set(playercount.get(), user.key())
							playercount.modify (v) -> v+1

		Obs.observe !->
			pl = Form.hidden 'players'
			ct = Form.hidden 'playercount'
			pl.value JSON.stringify(players.get())
			ct.value playercount.get()
