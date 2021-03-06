defmodule Elow.Wwwest do
	use Silverb, [
		{"@colors", ["white","red","yellow","pre","json"]}
	]
	require Wwwest
	Wwwest.callback_module do
		def handle_wwwest(%Wwwest.Proto{cmd: "message", args: %{app: app, message: message, color: color}}) when (is_binary(app) and (color in @colors)) do
			%Myswt.Proto{subject: "message", content: %{app: app, message: message, color: color, uuid: Exutils.make_uuid}} |> Myswt.send_all
			"ok"
		end
	end
end

defmodule Elow.Myswt do
	use Silverb
	require Myswt
	Myswt.callback_module do
	end
end
