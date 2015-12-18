defmodule ElowTest do
	use ExUnit.Case
	doctest Elow
	@colors ["white","red","yellow","pre","json"]

	@tag timeout: :timer.minutes(60)
	test "the truth" do
		send_mess
		assert 1 + 1 == 2
	end

	defp send_mess(n \\ 0) do
		mess = 	case Enum.at(@colors,rem(n,length(@colors))) do
					color = "json" -> %{cmd: "message", args: %{app: "elow", message: %{hello: 1, world: n, qwe: [100,2000,3000,%{a: 1, b: [1,2,3], c: "qweqwe"}]}, color: color}}
					color -> %{cmd: "message", args: %{app: "elow", message: "hello\nworld\n#{n}", color: color}}
				end
				|> Jazz.encode!
		[_,_,_,"ok"] = :os.cmd('curl -d \'#{mess}\' -u login:password http://127.0.0.1:8887') |> to_string |> String.split("\n")
		:timer.sleep(500)
		send_mess(n+1)
	end

end
