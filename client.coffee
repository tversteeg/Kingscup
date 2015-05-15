﻿Page = require 'page'
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
	playercount = Obs.create(Db.shared.get 'settings', 'playercount')
	players = JSON.parse(Db.shared.get 'settings', 'players')
	current = getUser(Db.shared.get 'turn')

	if +Plugin.userId() is +current
		Dom.div !->
			Dom.text "Your turn!"

		Dom.div !->
			Dom.style
				display: 'inline-block'
				width: '80%'
				height: '80%'
				background: "url(#{Plugin.resourceUri('back.jpg')}) 100% 100% no-repeat"
				backgroundSize: 'contain'

		Modal.show "Draw a card", !->
			Dom.style width: '80%'
			Dom.div !->
				Dom.style
					maxHeight: '40%'
					overflow: 'auto'
					backgroundColor: '#eee'
					margin: '-12px'
				Ui.bigButton "Draw a card", !->
					next = +(Db.shared.get 'turn') + 1
					if next >= +playercount
						next = 0

					Server.call 'nextTurn', next
					Modal.remove()
	else
		if currentcard = Db.shared.get 'currentcard'
			cardrules = ["Rule", "Snake eyes", "All girls drink", "All boys drink", "Forbidden word", "Give someone a drink", "\"Juffen\"", "Mate", "Category", "Rule", "Nickname", "Quiz master", "Kingscup!", "Rhyme"]
			cardtype = +currentcard % 12

			cardtext = cardrules[cardtype]
			cardimage = currentcard + '.png'
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

		Dom.div !->
			Dom.text cardtext
			Dom.style
				margin: '0 auto'
				fontSize: '200%'
				textAlign: 'center'

		Dom.div !->
			Ui.avatar Plugin.userAvatar(current)
			Dom.text "#{Plugin.userName(current)}'s turn!"
			Dom.style
				margin: '0 auto'
				fontSize: '120%'
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
