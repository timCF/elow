#
#	constants, defaults as callbacks arity 0
#
constants =
	default_opts: () -> {
		blocks: [{val: "main_page", lab: "данные"}]
		sidebar: false
		showing_block: "main_page"
		version: '__VERSION__'
	}
	colors: () -> {red: '#CC3300', yellow: '#FFFF00', pink: '#FF6699'}
#
#	state for jade
#

init_state =
	data: {
		stack_size: 20,
		logging: false,
		grep_app: "",
		grep_log: "",
		cache: {
			stack: []
		}
	}
	handlers: {
		#
		#	app local handlers
		#
		grep: (content,selector) ->
			if selector
				content.indexOf(selector) > -1
			else
				true
		#
		#	some main-purpose handlers
		#
		change_from_view: (path, ev) ->
			if (ev? and ev.target? and ev.target.value?)
				tmp = ev.target.value
				actor.cast( (state) -> Imuta.put_in(state, path, tmp) )
		change_from_view_swap: (path) -> actor.cast( (state) -> Imuta.update_in(state, path, (bool) -> not(bool)) )
		show_block: (some) -> actor.cast( (state) -> (state.opts.showing_block = some) ; state )
		#
		#	local storage
		#
		get_last_version: () ->
			val = actor.get().data.cache.last_version
			if not(val)
				res = $.ajax({type: 'GET', async: false, url: "http://"+location.host+"/version.json"}).responseJSON.versionExt
				actor.cast((state) ->
					if Imuta.is_string(res) then state.data.cache.last_version = res
					state)
				res
			else
				val
		reset_opts: () -> actor.cast((state) ->
			state.opts = constants.default_opts()
			store.remove("opts")
			warn("Опции сброшены до значений по умолчанию")
			state)
		save_opts: () -> actor.cast((state) ->
			store.set("opts", state.opts)
			notice("Опции сохранены")
			state)
		# use it only on start of application
		load_opts: () ->
			from_storage = store.get("opts")
			if from_storage then actor.cast((state) -> state.opts = from_storage ; state) else actor.get().handlers.reset_opts()
			last_version = actor.get().handlers.get_last_version()
			actor.cast((state) ->
				this_version = state.opts.version
				if not(Imuta.equal(this_version, last_version)) then error("Доступен клиент версии "+last_version+" но, вы используете клиент версии "+this_version+". Настоятельно рекомендуется сбросить опции, почистить кеш и обновить страницу.")
				state.opts.showing_block = constants.default_opts().showing_block
				state.opts.sidebar = constants.default_opts().sidebar
				state)
	}
#
#	actor to not care abount concurrency
#
actor = new Act(init_state, "pure", 500)
#
#	static clean inner handlers
#

#	TODO?

#
#	messages
#
to_server = (subject, content) ->
	bullet.send(JSON.stringify({"subject": subject,"content": content}))
#
#	view renderers
#
widget = require("widget")
domelement    = null
do_render = () ->
	this_state = actor.get()
	if this_state and domelement then React.render(widget(this_state), domelement)
render_process = () ->
	try
		do_render()
	catch error
		console.log error
	setTimeout( (() -> actor.zcast(() -> render_process())) , 500)
#
#	notifications
#
error = (mess) ->
	$.growl.error({ message: mess , duration: 20000})
warn = (mess) ->
	$.growl.warning({ message: mess , duration: 20000})
notice = (mess) ->
	$.growl.notice({ message: mess , duration: 20000})
#
#	bullet handlers
#
bullet = $.bullet("ws://" + location.hostname + ":8888/bullet")
document.addEventListener "DOMContentLoaded", (e) ->
	domelement  = document.getElementById("main_frame")
	actor.get().handlers.load_opts()
	actor.zcast(() -> render_process())
	bullet.onopen = () -> notice("bullet websocket: соединение с сервером установлено")
	bullet.ondisconnect = () -> error("bullet websocket: соединение с сервером потеряно")
	bullet.onclose = () -> warn("bullet websocket: соединение с сервером закрыто")
	bullet.onheartbeat = () -> to_server("ping","nil")
	bullet.onmessage = (e) ->
		mess = $.parseJSON(e.data)
		subject = mess.subject
		content = mess.content
		switch subject
			when "pong" then "ok"
			when "error" then error(content)
			when "warn" then warn(content)
			when "notice" then notice(content)
			when "message"
				actor.cast((state) ->
					mess_content = JSON.stringify(content.message)
					if (state.data.logging and state.handlers.grep(content.app,state.data.grep_app) and state.handlers.grep(mess_content,state.data.grep_log))
						content.date = Date()
						state.data.cache.stack.unshift(content)
						state.data.cache.stack = state.data.cache.stack.slice(0, state.data.stack_size)
						do_render()
						state.data.cache.stack.forEach((this_subj) ->
							if (this_subj.color == "json")
								(new PrettyJSON.view.Node({el: $('#'+this_subj.uuid), data: this_subj.message})))
					state)
			else
				alert("subject : "+subject+" | content : "+content)
