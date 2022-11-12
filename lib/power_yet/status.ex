defmodule PowerYet.Status do
  use Ecto.Schema
  alias Ecto.Multi

  alias PowerYet.Repo
  alias __MODULE__

  schema "status" do
    timestamps()
    field(:last_import_at, :utc_datetime)
  end

  def get do
    Status
    |> Repo.one!()
  end

  def multi_update_last_import_at(time \\ utc_now()) do
    Multi.new()
    |> Multi.update_all(:update_last_import_at, Status, set: [last_import_at: time])
    |> Multi.run(:assert_last_import_at, fn _, %{update_last_import_at: result} ->
      multi_assert_one_updated(result)
    end)
  end

  defp utc_now do
    DateTime.utc_now()
    |> DateTime.truncate(:second)
  end

  defp multi_assert_one_updated({1, _}), do: {:ok, 1}
  defp multi_assert_one_updated({n, _}), do: {:error, "expected 1 record updated, got #{n}"}
end
