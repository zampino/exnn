# EXNN
_Evolutive Neural Networks framework à la G.I.Sher written in Elixir_


# Preliminary Notice
The work presented here is _strongly_ influenced
by the seminal book [Handbook of Neuroevolution Through Erlang](http://www.springer.com/de/book/9781461444626) by Gene I. Sher, which is a vast source of inspiring concepts and thoughts on the topic.

Needless to say, all erlang-specific concepts and the algorithmic
toolsets are to be credited the author of the book.
In a later section I will outline which approaches of the code I can
claim as original.

I went through the effort of not just translating from Erlang
the code examples in the book, but tried to exploit (and learn!) Elixir idioms and
their expressive power - along with OTP patterns - interpreting the shapes
and construct of the book.

Pleas note that at present this library is at a very early stage,
and it's impossible for me to tell where it will lead. Any kind of
help or suggestions on the code is warmly appreciated.
The future of `EXNN` is strictly unsupervised.

# Usage
To use EXNN you will first mix EXNN as dependency and then
push `EXNN.Supervisor` module in the stack
of your application's supevised children. Your main application file
will also serve as configuration for customizing initial conditions
of the system:

### Configuration

```elixir

defmodule MyApp do
  use EXNN.Application

  sensor :temp, MyApp.TempSensor, dim: 1
  sensor :wind, MyApp.WindSensor, dim: 2
  actuator :servo, MyApp.WindowServo

  fitness MyApp.Fitness

  initial_pattern [
    sensor: [:temp, :wind],
    neuron: {2, 3, 3, 2},
    actuator: [:servo]
  ]

  def start(_, _) do
    import Supervisor.Spec
    children = [
      supervisor(MyApp.MainSupervisor),
      # ... all these beautiful supervised boys
      supervisor(EXNN.Supervisor, [[config: __MODULE__]])
    ]

    Supervisor.start_link children, [strategy: :one_for_one]
  end
end

```
Note `EXNN.Application` is just a wrapper around Elixir/OTP `Application` module,
exposing the configuration DSL.

With `sensor` and `actuator` macros,
you can register the type for sensor and actuator modules. For sensors
you have to specify the dimension of the signal vector.

With the `fitness` macro you register a fitness module wich will
compute in real time how much the present system is close to (one of the)
optimal configuration and topology, more on this later.

`initial_pattern` decides the initial topology for your network, it's a
Keyword accepting the 3 keys above. You can only mention previously registered
sensors and actuators. The value for `neuron` key has to be a tuple denoting
the size of each neural layer you want your system to start with.
In the above example, the initial_pattern given would correspond to the digraph:

![digraph](digraph.png)

where all elements in a layer are connected to all vertices of the following.


### Sensors
Your sensor module will use `EXNN.Sensor`. At its heart is an OTP genserver.
You have to implement the function `sense/2` which is called when
`EXNN.Trainer` synchronizes all sensors in the system.

On the other hand,
since it's a genserver registered with its module name, you can reach it
from whatever external service providing sample data:

```elixir
defmodule MyApp.TempSensor do
  use EXNN.Sensor, state: %{outer_temp: 0}

  def sense(state, _metadata) do
    {state.outer_temp}
  end

  def handle_cast({:update_temp, value}, state) do
    {:noreply, %{state | outer_temp: value}}
  end
end

defmodule MyApp.WindSensor do
  use EXNN.Sensor, state: %{speed: 0, direction: 0 * :math.pi}

  def sense(state, _meta) do
    {state.speed, state.direction})
  end

  # ...some callbacks to update state...
end
```

`sense/2` forwards the desired
signal to the front neuronal layer.
It takes the current state of the sensor and a tuple of scalar
values of the same length as the configured dimension.
Read more about sensors in the [docs](http://zampino.github.io/exnn)


### Actuators
Using `EXNN.Actuator` in your modules you can setup a genserver
which reacts to signals coming from the terminal neural layer.

You have to
implement an `act/3` method which takes the current state,
a scalar signal arrived and some metadata (more on
metadata later). `act/3` can have the side-effects you desire
and must return the modified state e.g:

```elixir
defmodule MyApp.WindowServo do
  use EXNN.Actuator, state: %{current: 0}

  def act(state, message, _metadata) do
    {:ok, new_val} = MyApp.WindowServo.Command.turn(message)
    %{state | current: new_val}
  end

end

```
read more [docs](http://zampino.github.io/exnn)

### Fitness
A Fitness module evaluates how the system is performing in real-time,
it's your responsibility to implement an `eval/3` function taking the same
`message` passed to the actuator, the usual metadata and it's state.

a fitness value.
The learning system will call eval in your module right after your
actuator has changed the environment.

**[TODO] pass actuator state to eval**


```elixir
defmodule MyApp.Fitness do
  use EXNN.Fitness, state: %{inner_temp: 0.0, outer_temp: 40.0}

  def eval(_message, _metadata, state) do
    diff = state.outer_temp - get_inner_temp
    fitness = 1/(1 + :math.pow(diff, 2))
    emit(fitness)
    state
  end

  def get_inner_temp do
    # ask inner temperature...
  end

end

```

# Examples
At present you can only run EXNN over tests, check out
how to train a basic XOR problem by running

# Present State

# Future Plans
- State Machine for states 'loading'/'learning'/'production'.
State should switch to 'production' whenever fitness enters a tolerance
neighborhood of 1.

- Explorative search to split an individuum into two or more.  

- Spawn a population of nets through routing

# Features



# References

1. Gene.I.Sher, _Handbook of Neuroevolution Through Erlang_, 2013, Springer
