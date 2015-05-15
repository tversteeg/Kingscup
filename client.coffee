Page = require 'page'
Form = require 'form'
Plugin = require 'plugin'
Ui = require 'ui'
Dom = require 'dom'
Obs = require 'obs'
Db = require 'db'
Server = require 'server'
Modal = require 'modal'

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

#		Server.call "addUser", userId
	playercount = Db.shared.get 'settings', 'playercount'
	players = JSON.parse(Db.shared.get 'settings', 'players')
	turn = Db.shared.get 'turn'
	current = getUser(turn)

	if +Plugin.userId() is +current
		Dom.div !->
			Dom.style
				display: 'inline-block'
				width: '90%'
				height: '90%'
				margin: '0 auto'
				background: "url(#{Plugin.resourceUri('back.jpg')}) 100% 100% no-repeat"
				backgroundSize: 'contain'

		Dom.div !->
			Dom.text "Your turn!"
			Dom.style
				fontSize: '200%'
				textAlign: 'center'

		Modal.show "Draw a card", !->
			Dom.style width: '80%'
			Dom.div !->
				Dom.style
					maxHeight: '40%'
					overflow: 'auto'
					backgroundColor: '#eee'
					margin: '-12px'
				Ui.bigButton "Draw a card", !->
					next = +turn + 1
					if +next >= playercount
						Server.call 'nextTurn', 0
					else
						Server.call 'nextTurn', next

					Modal.remove()
	else
		if currentcard = Db.shared.get 'currentcard'
			cardrules = [
				"Rule",# 10
				"Snake eyes",# 2
				"All girls drink",# 3
				"All boys drink",# 4
				"Forbidden word",# 5
				"Give someone a drink",# 6
				"\"Juffen\"",# 7
				"Mate",# 8
				"Category",# 9
				"Rhyme",# Ace
				"Nickname",# Jack
				"Kingscup!",# King
				"Quiz master"# Queen
			]
			cardtype = Math.floor(+currentcard / 4)

			cardtext = cardrules[cardtype]
			cardimage = currentcard + '.png'

			previous = +turn - 1
			if previous < 0
				previous = +playercount - 1
			messagetext = Dom.text Plugin.userName(getUser(previous)) + " has drawn:"
		else
			cardtext = "The first card needs to be drawn"
			cardimage = 'back.jpg'

		Dom.div !->
			Dom.style
				width: '75%'
				height: '75%'
				margin: '0 auto'
				background: "url(#{Plugin.resourceUri(cardimage)}) 100% 100% no-repeat"
				backgroundSize: 'contain'

		if messagetext
			Dom.div !->
				Dom.text messagetext
				Dom.style
					margin: '0 auto'
					fontSize: '120%'
					textAlign: 'center'

		Dom.div !->
			Dom.text cardtext
			Dom.style
				margin: '0 auto'
				fontSize: '200%'
				textAlign: 'center'

		Dom.div !->
			Dom.text Plugin.userName(current) + "'s turn!"
			Dom.style
				margin: '0 auto'
				fontSize: '150%'
				textAlign: 'center'

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
						if +user.key() is +Plugin.userId()
							Dom.text "You"
						else
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
