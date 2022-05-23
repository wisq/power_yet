defmodule PowerYetWeb.SearchView do
  use PowerYetWeb, :view

  def direction(d) when d < 0.0 or d > 360.0, do: raise(ArgumentError)

  def direction(d) when d < 11.25, do: "north"
  def direction(d) when d < 33.75, do: "north-northeast"
  def direction(d) when d < 56.25, do: "northeast"
  def direction(d) when d < 78.75, do: "east-northeast"
  def direction(d) when d < 101.25, do: "east"
  def direction(d) when d < 123.75, do: "east-southeast"
  def direction(d) when d < 146.25, do: "southeast"
  def direction(d) when d < 168.75, do: "south-southeast"
  def direction(d) when d < 191.25, do: "south"
  def direction(d) when d < 213.75, do: "south-southwest"
  def direction(d) when d < 236.25, do: "southwest"
  def direction(d) when d < 258.75, do: "west-southwest"
  def direction(d) when d < 281.25, do: "west"
  def direction(d) when d < 303.75, do: "west-northwest"
  def direction(d) when d < 326.25, do: "northwest"
  def direction(d) when d < 348.75, do: "north-northwest"
  def direction(d) when d <= 360.0, do: "north"
end
