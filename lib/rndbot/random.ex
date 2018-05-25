# Copyright 2015 Ahmet Cetinkaya

# This file is part of RndBot.

# RndBot is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# RndBot is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with RndBot.  If not, see <http://www.gnu.org/licenses/>.

defmodule RndBot.Random do
  def rand(min, max) when min < max and min >= 1 and max <= 10000 do
    url = "https://www.random.org/integers/?num=1&min=#{min}&max=#{max}&col=1&base=10&format=plain&rnd=new"
    :hackney.start
    number = case :hackney.request("get", to_char_list(url), [], '', []) do
               {:ok, _, _, c} ->
                 case :hackney.body(c) do
                   {:ok, body} ->
                     {n, _} = (body |> String.trim() |> Integer.parse())
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
