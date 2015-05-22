defmodule RndBot.Random do
  def rand(min, max) when min < max and min >= 1 and max <= 10000 do
    url = "https://www.random.org/integers/?num=1&min=#{min}&max=#{max}&col=1&base=10&format=plain&rnd=new"
    :hackney.start
    number = case :hackney.request("get", to_char_list(url), [], '', []) do
               {:ok, _, _, c} ->
                 case :hackney.body(c) do
                   {:ok, body} ->
                     {n, _} = (body |> String.strip() |> Integer.parse())
                     n
                   _ -> -1
                 end
               _ -> -1
             end
    :hackney.stop
    number
  end

  def rand(min, _) do
    min
  end
end
