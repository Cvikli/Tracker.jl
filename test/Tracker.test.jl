
# TRACK anything anytime!
fn(x) = begin
  y=x+8+x*x
  @track :y y  # Suppose the y is a REALLY important and complex structure that you just don't want to return through the functions, just for debug purposes. Simply track it!
  z=y * (x + 4)
  return z
end
fn(3)
@show tracked[:y] # It's a dict, in which we track every single value we pushed into it, we just have to know which key did we push our tracked variables.




using Tracker: @track
gn() = begin
	sleep(0.2) 
	res = 5*5*5*3*rand(Float32,2,3)
	@track :ournumber res  # <------
	println("Ready...")
	return 3
end
gn()

#%%
using Tracker: tracked
tracked[:ournumber]

