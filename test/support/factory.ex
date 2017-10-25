defmodule HappoWeb.Factory do
  @moduledoc """
  This module allow to either build a struct or create that element in
  the database.

  Builds a struct of the provided `factory_name`.

      iex> Factory.build_factory(:post, title: "My post")
      %Post{title: "MyPost"}

  Create the `factory_name` element into database.

      iex> Factory.create!(:post, title: "new post")
      %Post{id: 1, title: "new post"}

  Note that we are not using changeset to ensure the element is valid!
  """

  alias Happo.Repo

  #─────────────────────────────────────────────────────────────────────
  # Convenience API
  #─────────────────────────────────────────────────────────────────────
  @doc """
  Builds a struct of the provided `factory_name`.

      iex> Factory.build_factory(:post, title: "My post")
      %Post{title: "MyPost"}

  Note that post is not checked or validated.

      iex> Factory.build_factory(:post, title: nil)
      %Post{title: nil}
  """
  def build(factory_name, attributes \\ []) do
    # Use matching factory build function using its factory defaults
    factory(factory_name)
    # Convert from changeset to `factory_name` struc
    |> struct(attributes)
  end

  @doc """
  Insert the `factory_name` element into database.
      iex> Factory.create!(:post, title: "new post")
      %Post{id: 1, title: "new post"}
  """
  def create!(factory_name, attributes \\ []) when is_atom(factory_name) do
    build(factory_name, attributes) |> Repo.insert!()
  end

  #─────────────────────────────────────────────────────────────────────
  # Factories. Returns a `factory_name` struct.
  #
  # Example:
  #
  #   iex> factory(:user)
  #   %Happo.Registration.User{email: "ivan@example.com", ...}
  #─────────────────────────────────────────────────────────────────────
  defp factory(:user) do
    struct(Happo.Registration.User, %{
      email:            "user#{unique_integer()}@example.com",
      terms_of_service: true,
      first_name:       Enum.random(~w[Leo Mike Ralph Donatello]),
      last_name:        Enum.random(~w[Wan Chang Liu Chang]),
      password:         "mysecretpassword",
    })
  end

  #─────────────────────────────────────────────────────────────────────
  # Small helpers
  #─────────────────────────────────────────────────────────────────────
  defp unique_integer, do: System.unique_integer([:positive,:monotonic])



end
