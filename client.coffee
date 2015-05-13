Page = require 'page'
Form = require 'form'
Plugin = require 'plugin'
Ui = require 'ui'
Dom = require 'dom'
Obs = require 'obs'
Db = require 'db'
Server = require 'server'

getUser = (num) !->
	return JSON.parse(Db.shared.get 'settings', 'players')[num]

# This is the main entry point for a plugin:
exports.render = ->
	if Plugin.users.count().get() < 2
		Ui.emptyText "You need at least 2 members in your happening group to play Kingscup"
		return

	if ! Db.shared.get 'settings', 'playercount'
		Ui.emptyText "You need players to play Kingscup"
		return

	userId = Plugin.userId()

#		Server.call "addUser", userId
	playercount = Obs.create(Db.shared.get 'settings', 'playercount')
	players = JSON.parse(Db.shared.get 'settings', 'players')
	current = getUser(Db.shared.get 'turn')

	Dom.div !->
		Dom.text "Players: "
		Dom.text playercount.get()
		Dom.style
			display: 'inline-block'
			width: '100%'

	Dom.div !->
		Dom.style
			display: 'inline-block'
			width: '80%'
			height: '80%'
			background: "url(#{Plugin.resourceUri('back.jpg')}) 100% 100% no-repeat"
			backgroundSize: 'contain'

	Dom.div !->
		Dom.text "#{Plugin.userName(current)}'s turn!"

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
