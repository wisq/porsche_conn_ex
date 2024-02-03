# PorscheConnEx

PorscheConnEx (aka PCX) is a library for connecting to the Porsche Connect API, to monitor and control your Porsche vehicle.

## Installation

PorscheConnEx requires Elixir v1.15 or later.  To use it, add `:porsche_conn_ex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:porsche_conn_ex, "~> 0.1.0"}
  ]
end
```

## Usage

```elixir
# Start a PorscheConnEx session:
{:ok, pid} = PorscheConnEx.Session.start_link(credentials: %{
  username: "user@domain.com", 
  password: "my_password"
}, name: MySession)

# Get a list of vehicles:
{:ok, vehicles} = PorscheConnEx.Client.vehicles(pid)

# Get a summary of the first vehicle (and output it):
vin = List.first(vehicles).vin
{:ok, summary} = PorscheConnEx.Client.summary(pid, vin)
summary |> IO.inspect(label: "Summary")

# Get the vehicle model:
{:ok, capabilities} = PorscheConnEx.Client.capabilities(pid, vin)
model = capabilities.car_model

# Get the current emobility data:
{:ok, emobility} = PorscheConnEx.Client.emobility(pid, vin, model)

# Output the current battery charge and estimated remaining distance:
emobility.charging.percent |> IO.inspect(label: "Percent charged")
emobility.charging.remaining_electric_range |> IO.inspect(label: "Remaining range")

# There's a lot of overlap in the various API calls -- you can get the same
# data via both `status/2` and `stored_overview/2`.  For example:
{:ok, status} = PorscheConnEx.Client.status(pid, vin)
{status.battery_level, status.remaining_ranges.electric.distance} |> IO.inspect(label: "Status")

# If you want the most current data, you can use `current_overview/2`, but it's slowww:
{:ok, pending} = PorscheConnEx.Client.current_overview(pid, vin)
{:ok, overview} = PorscheConnEx.Client.wait(pid, pending)
{overview.battery_level, overview.remaining_ranges.electric.distance} |> IO.inspect(label: "Overview")

# And since we named the process `MySession`, we can use that instead:
{:ok, position} = PorscheConnEx.Client.position(MySession, vin)
position.coordinates |> IO.inspect(label: "Position")
```

Output:

```elixir
Summary: %PorscheConnEx.Struct.Summary{model_description: "Taycan GTS", nickname: nil}
Percent charged: 80
Remaining range: #PCX:Distance<261.0 km>
Status: {#PCX:BatteryLevel<80%>, #PCX:Distance<261.0 km>}
Overview: {#PCX:BatteryLevel<80%>, #PCX:Distance<261.0 km>}
Position: %PorscheConnEx.Struct.Position.Coordinates{
  latitude: 45.678901,
  longitude: -76.543210,
  reference_system: :wgs84
}
```

## Documentation

Full documentation can be found at <https://hexdocs.pm/porsche_conn_ex>.

## Legal stuff

Copyright © 2024, Adrian Irving-Beer.

PorscheConnEx is released under the [MIT license](https://github.com/wisq/porsche_conn_ex/blob/main/LICENSE) and is provided with **no warranty**.  Use this code at your own risk, and be careful with what commands you issue to your (insanely expensive) vehicle.

PorscheConnEx is in no way associated with, or endorsed by, Porsche or any of their subsidiaries or associated companies.  "Porsche" and "Taycan" are registered trademarks of Porsche, and their use in this library are only for the purposes of identifying and describing those products.  The API this library uses is unofficial and undocumented, and is subject to change at any time and without warning, potentially breaking this library.
