Db = require 'db'
Plugin = require 'plugin'
Event = require 'event'

exports.onInstall = (config) ->
	if config
		# set the counter to 0 on plugin installation
		Db.shared.set 'players', +config

		Event.create
			unit: 'game'
			text: "Kingscup: #{Plugin.userName()} wants to play"
			# for: x=[+config.white, +config.black]
			new: [-Plugin.userId()]

exports.client_event = !->
	Event.create
		text: "You're turn!"

exports.client_addUser = (user) ->
	maxId = Db.shared.modify "ids", (v) -> v+1
	Db.shared.set "users", maxId, {user: user}
