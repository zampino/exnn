defmodule EXNN.Utils.Task do

  def wait_all(tasks, timeout\\5000) do
    process_tasks(tasks, %{}, timeout)
  end

  def process_tasks([], done, _timeout), do: done

  def process_tasks([%Task{ref: ref}=task | rest], done, timeout) do
    receive do
      {^ref, reply} ->
        Process.demonitor(ref, [:flush])
        process_tasks(rest, Map.put(done, ref, reply), timeout)
      {:DOWN, ^ref, _, _, :noconnection} ->
        mfa = {__MODULE__, :await, [task, timeout]}
        exit({{:nodedown, node(task.pid)}, mfa})
      {:DOWN, ^ref, _, _, reason} ->
        exit({reason, {__MODULE__, :await, [task, timeout]}})
    after
      timeout ->
        Process.demonitor(ref, [:flush])
        exit({:timeout, {__MODULE__, :await, [task, timeout]}})
    end
  end
end
