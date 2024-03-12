module Tracker

export @track
export tracked

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
			!($var_sym in keys(Tracker.tracked)) && (Tracker.tracked[$var_sym] = typeof($res)[]);
			push!(Tracker.tracked[$var_sym], $res)
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



is_it_reproducible(syms::Matrix{Symbol}; silent=false) = is_it_reproducible(syms, silent)
is_it_reproducible(syms::Matrix{Symbol}, silent) = is_it_reproducible.(syms, silent)

is_it_reproducible(syms::Vector{Symbol}; silent=false) = is_it_reproducible(syms, silent)
is_it_reproducible(syms::Vector{Symbol}, silent) = is_it_reproducible.(syms, silent)

is_it_reproducible(sym::Symbol; silent=false) = is_it_reproducible(sym, silent)
is_it_reproducible(sym::Symbol, silent) = begin
	global tracked
	!(sym in keys(tracked)) && ((!silent && println("$sym: doesn't exist!")); return 3)
	length(tracked[sym]) < 2 && ((!silent && println("$sym: isn't ready")); return 2)
	is_last_two_similar(sym, tracked[sym][end], tracked[sym][end-1], silent)
end

is_last_two_similar(sym, arr1, arr2, silent) = begin
	if is_similar(arr1, arr2)
		!silent && println("$sym: ✔")
		return 1
	else
		!silent && println("$sym: asymetry in the data! (something undef or seed wasn't set?)")
		return 0
	end
end

is_similar(arr1::AbstractArray{Int,N},     arr2::AbstractArray{Int,N})     where N = is_similar(Array(arr1), Array(arr2))
is_similar(arr1::AbstractArray{Float32,N}, arr2::AbstractArray{Float32,N}) where N = is_similar(Array(arr1), Array(arr2))
is_similar(arr1::Array{Int,N},             arr2::Array{Int,N})             where N = all(arr1 .== arr2)
is_similar(arr1::Vector{Int32},            arr2::Vector{Int32})                    = all(arr1 .== arr2)
is_similar(arr1::Array{Float32,N},         arr2::Array{Float32,N})         where N = all(isapprox.(arr1, arr2, rtol=3e-3))
is_similar(v1::Float32, v2::Float32)  = isapprox(v1, v2, rtol=3e-3)
is_similar(v1::Int,     v2::Int)      = v1 == v2



end # module Tracker


