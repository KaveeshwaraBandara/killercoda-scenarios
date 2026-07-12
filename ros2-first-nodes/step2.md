# Make two nodes talk

Start the **talker** — a node that publishes `Hello World: N` to the `/chatter` topic once per second. We'll keep it running in the background so we can start a second node in the same terminal:

```bash
ros2 run demo_nodes_cpp talker > /tmp/talker.log 2>&1 &
```{{exec}}

It's alive — peek at what it's publishing:

```bash
tail -n 3 /tmp/talker.log
```{{exec}}

Now start the **listener**, a *different program in a different language* (Python, while the talker is C++), which subscribes to `/chatter`:

```bash
ros2 run demo_nodes_py listener
```{{exec}}

Watch the messages arrive — `I heard: [Hello World: N]`, once per second, numbers matching what the talker sends. Two independent programs, communicating through a named topic, with no direct connection between them. That's the fundamental pattern of every ROS 2 robot.

When you've seen enough, stop the listener with `Ctrl+C` (the talker keeps running in the background — we still need it).
