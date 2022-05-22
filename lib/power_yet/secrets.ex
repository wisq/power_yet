defmodule PowerYet.Secrets do
  require Logger

  def fetch!(key, type \\ :string) do
    case fetch(key) do
      {:ok, value} -> value |> to_type(type)
      :error -> raise "Secret for #{inspect(key)} not found in environ"
    end
  end

  def fetch(key), do: System.fetch_env(key)

  defp to_type(str, :string), do: str
  defp to_type(str, :integer), do: String.to_integer(str)

  # Dev mode only:
  def load_env_from_path(path) do
    case File.ls(path) do
      {:ok, files} ->
        count =
          Enum.map(files, fn key -> load_env_from_file(key, Path.join(path, key)) end)
          |> Enum.count(fn rv -> rv == :ok end)

        Logger.debug("Loaded #{count} environment variables from #{path}")

      {:error, _} ->
        :ignore
    end
  end

  defp load_env_from_file(key, file) do
    if File.regular?(file) do
      value = File.read!(file) |> :string.chomp()
      System.put_env(key, value)
      :ok
    else
      Logger.debug("Not loading non-regular file #{file}")
      :error
    end
  end
end
