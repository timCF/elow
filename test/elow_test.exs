defmodule ElowTest do
	use ExUnit.Case
	doctest Elow
	@colors ["white","red","yellow"]

	@tag timeout: :timer.minutes(60)
	test "the truth" do
		send_mess
		assert 1 + 1 == 2
	end

	defp send_mess(n \\ 0) do
		mess = %{cmd: "message", args: %{app: "elow", message: "hello #{n}", color: Enum.at(@colors,rem(n,length(@colors)))}} |> Jazz.encode!
		[_,_,_,"ok"] = :os.cmd('curl -d \'#{mess}\' -u login:password http://127.0.0.1:8887') |> to_string |> String.split("\n")
		:timer.sleep(500)
		send_mess(n+1)
	end

end
