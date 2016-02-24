# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :exnn,
  max_generation: 10_000
# config :docs, [main: "extra-readme"]
# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for third-
# party users, it should be done in your mix.exs file.


sys_level = case System.get_env("LOG_LEVEL") do
  nil -> nil
  flag -> String.to_atom(flag)
end

# Sample configuration:
#
config :logger, :console,
  level: sys_level || :info,
  format: "$date $time [$level] $metadata$message\n",
  metadata: [:user_id]


# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env}.exs"
