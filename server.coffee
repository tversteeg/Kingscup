Db = require 'db'
Plugin = require 'plugin'
Event = require 'event'

exports.onInstall = (config) ->
	if config?
		# set the counter to 0 on plugin installation
		Db.shared.set 'settings', 'players', config.players
		Db.shared.set 'settings', 'playercount', config.playercount
		Db.shared.set 'turn', Math.round(Math.random() * config.playercount)

	Event.create
		unit: 'game'
		text: "Kingscup: #{Plugin.userName()} wants to play"
		new: [-Plugin.userId()]

exports.client_event = !->
	Event.create
		text: "Your turn!"
		new: [+Db.shared.get('turn')]

exports.client_addUser = (user) ->
	maxId = Db.shared.modify "ids", (v) -> v+1
	Db.shared.set "users", maxId, {user: user}
