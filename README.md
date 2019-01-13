# createevent-delphi
Basic delphi code illustrating the use of createvent, setevent, waitforsingleobject but also queueuserapc and setthreadcontext.

-Demo1

createevent

create wait1 thread : wait for event to be signaled in a loop

setevent repeatedly

thread will wakeup each time

-Demo2

ceatevent

create wait2 thread : wait for event to be signaled and exit

setevent

thread terminates

-Demo3

createevent

create sleep1 thread : sleep 5 secs and increment a variable

QueueUserAPC & wait2 : inject wait2 in above thread, will freeze sleep1

setevent

wait2 code terminates

sleep1 resumes

-Demo4

createevent

create sleep1 thread : sleep 5 secs and increment a variable

QueueUserAPC & setevent : inject setevent in above thread (passing our event handle param)

sleep1 will resume at once (sleepex is alertable)

-Demo5

createevent

create sleep1 thread : sleep 5 secs and increment a variable

SetThreadContext : pause, inject a code (wait2) in above thread, change its eip, resume

sleep1 will not resume

setevent : wait2 code will detect signaled event and terminates

sleep1 will resume

