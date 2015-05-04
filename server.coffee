Db = require 'db'

exports.onInstall = ->
	# set the counter to 0 on plugin installation
	Db.shared.set 'counter', 0
