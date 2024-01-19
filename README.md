# Tracker.jl
Track ANYTHING anywhere in your functions.


## Usage
```julia
using Tracking: tracked, elapsed

@track :label expr  # Track results
@elaps :label expr  # Track timings

@show tracked[:label]
@show elapsed[:label]

```
