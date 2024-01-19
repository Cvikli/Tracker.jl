module Tracker


global tracked = Dict()
global elapsed = Dict()
get_tracked() = (global tracked; return tracked)

# is_tracking_disabled() = true  # code has to be rebuilt!
is_tracking_disabled() = false  # code has to be rebuilt!
macro track(var, ex)
	is_tracking_disabled() && return esc(ex)
	res = gensym()
	var_sym = var
	return esc(quote
			$res = $ex;
			!($var_sym in keys(tracked)) && (tracked[$var_sym] = typeof($res)[]);
			push!(tracked[$var_sym], $res)
			$res
	end)
end



macro elaps(col, ex)
	quote
			local t0 = time_ns()
			$(esc(ex))
			!($(esc(col)) in keys(elapsed)) && (elapsed[$(esc(col))] = Float32[])
			push!(elapsed[$(esc(col))], (time_ns() - t0) / 1e9)
	end
end


end # module Tracker


