defmodule EXNN.EventsTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, pid} = EXNN.Events.start_link

    on_exit fn ->
      Process.exit pid, :normal
    end

    {:ok, [events: pid]}
  end

  test "should run a stream", %{events: e} do
    :timer.sleep 10
    EXNN.Events.Manager.notify :info, {self, 1}
    EXNN.Events.Manager.notify :whatever, "Hallo!!!"
    EXNN.Events.Manager.notify :whatever, "Hallo!!!"
    EXNN.Events.Manager.notify :whatever, "Hallo!!!"
    EXNN.Events.Manager.notify :whatever, "Hallo!!!"
    EXNN.Events.Manager.notify :whatever, "Hallo!!!"
    EXNN.Events.Manager.notify :whatever, "Hallo!!!"
    EXNN.Events.Manager.notify :whatever, "Hallo!!!"
    EXNN.Events.Manager.notify :whatever, "Hallo!!!"
    EXNN.Events.Manager.notify :whatever, "Hallo!!!"
    EXNN.Events.Manager.notify :whatever, "Hallo!!!"
    EXNN.Events.Manager.notify :whatever, "Hallo!!!"
    EXNN.Events.Manager.notify :whatever, "Hallo!!!"
    assert_receive "received 1"
  end

end
