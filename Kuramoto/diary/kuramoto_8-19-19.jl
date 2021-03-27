# kuramoto_8-19-19.jl
# I've worked my way up to tasks/coroutines in the manual.
#
# https://docs.julialang.org/en/v1/manual/control-flow/#man-tasks-1
#
# Pretty wild stuff, but I need to play around with them
# a bit to really get a handle on how they work.

function producer(c::Channel)
    put!(c, "Channel initialized.")
    for n = 1:100
        sleep(5) # Hang for 5 seconds, arbitrarily.
        put!(c, n)
    end
    put!(c, "Channel completed.")
end

# How long does this code take to run? are the producer
# tasks always running in the background, generating and
# storing values, or is it more like lazy evaluation? I'll
# need to do some experiments to find out.



#----------------------------------------------------------#

# First, the most basic test.

channel_1 = Channel(producer)

@time begin
    @time println(take!(channel_1))
    @time println(take!(channel_1))
    @time println(take!(channel_1))
end



#----------------------------------------------------------#


channel_2 = Channel(producer)

@time begin
    @time println(take!(channel_2))
    @time sleep(2)
    @time println(take!(channel_2))
    @time sleep(2)
    @time println(take!(channel_2))
end

# Oh, holy shit, no. The producers DO run in the background,
# even when other functions are working. Both of these run
# at around 10 seconds apiece.



#----------------------------------------------------------#




channel_3 = Channel(producer)

@time begin
    @time println(take!(channel_3))
    @time sleep(10)
    @time println(take!(channel_3))
    @time sleep(10)
    @time println(take!(channel_3))
end

# Final test. If this runs at 20 seconds, it's evidence that
# the producers are running even when I'm not take!ing from
# them. If this runs at 30 seconds, it's evidence that they
# only fire up to produce the next value once I call the
# take! function. If it's something else... I don't know.

# 20 seconds. So the producers can run in the background.



#----------------------------------------------------------#

# Okay, next question. We know it runs in the background
# until the next call. But does it run until it has a value
# to return, and *then* hang? Or does it keep running so it
# has a stockpile of values just in case? My guess is
# actually the latter, but I wonder if there's some way to
# force the behavior of the former. Let's test it.

# If it stores multiple values, then a sleep value larger
# than all of the 5-second delays should lead to the values
# all spilling out at once. If it's only storing one value,
# this should take about 55 seconds, instead of 45.

channel_4 = Channel(producer)

@time begin
    @time println(take!(channel_4))
    @time sleep(45)
    @time println(take!(channel_4))
    @time println(take!(channel_4))
    @time println(take!(channel_4))
end

# 55 seconds! Aha! So it only works up until it put!s the
# next value, then it hands off to the next lad.



#----------------------------------------------------------#

# Okay, one last test. I think this one is pretty
# straightforward.

function producer_slow(c::Channel)
    put!(c, "Slow producer online!")
    while true
        sleep(7)
        put!(c, "x")
    end
end

function producer_fast(c::Channel)
    put!(c, "Fast producer online!")
    while true
        sleep(5)
        put!(c, "y")
    end
end

channel_x = Channel(producer_slow)
channel_y = Channel(producer_fast)

@time begin
    for i = 1:5
        @time println(take!(channel_y))
        @time println(take!(channel_x))
    end
end



#----------------------------------------------------------#

# Let's finally make some code for practicing actually
# making tasks.

producer(c::Channel, t) = while true put!(c, t) end

channel = Channel(producer)

take!(channel)

# MethodError, of course.

#----------------------------------------------------------#



producer(c::Channel, t) = while true put!(c, t) end

channel = Channel((c::Channel) -> producer(c, 5))

take!(channel)
take!(channel)
take!(channel)



#----------------------------------------------------------#






producer(c::Channel, t) = while true put!(c, t) end

channel = Channel(() -> producer(5))

take!(channel)
take!(channel)
take!(channel)



#----------------------------------------------------------#




producer(c::Channel, t) = while true put!(c, t) end

channel = Channel(producer(c,5))

take!(channel)
take!(channel)
take!(channel)



#----------------------------------------------------------#


# Okay, now let's get some practice with creating Tasks.

f(x) = sleep(x);
g(y) = sleep(y);

t1 = Task(() -> f(2));
t2 = @task g(3);


#----------------------------------------------------------#
