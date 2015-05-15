Db = require 'db'
Plugin = require 'plugin'
Event = require 'event'

exports.onInstall = (config) ->
	if config?
		# set the counter to 0 on plugin installation
		Db.shared.set 'settings', 'players', config.players
		Db.shared.set 'settings', 'playercount', config.playercount
		Db.shared.set 'turn', Math.floor(Math.random() * config.playercount)

		numarray = []
		for i in [0..51]
			numarray[i] = i + 1

		for cardnum in [1..52]
			Db.shared.set 'cards', cardnum, numarray.splice(Math.floor(Math.random() * numarray.length), 1)

	Event.create
		unit: 'game'
		text: "Kingscup: #{Plugin.userName()} wants to play"
		new: [-Plugin.userId()]

exports.getTitle = !->
	"Kingscup!"

exports.client_nextTurn = (next) ->
	Db.shared.set 'turn', next

	found = -1
	for cardnum in [1..52]
		if card = Db.shared.get 'cards', cardnum
			Db.shared.remove 'cards', cardnum
			found = card
			break

	Db.shared.set 'currentcard', found

	Event.create
		text: "Your turn!"
		new: [+next]
