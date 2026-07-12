# Eavesdrop on the topic

Nodes aren't the only ones who can listen. You — a human with a terminal — can inspect everything flowing through a ROS 2 system from the outside.

List the topics that exist right now:

```bash
ros2 topic list
```{{exec}}

There's `/chatter`, the channel your talker is still publishing on. Tap into it directly:

```bash
ros2 topic echo /chatter
```{{exec}}

You're seeing the raw messages, live. When debugging a real robot, this is exactly how you'll do it.

Stop the echo with `Ctrl+C`, then measure how fast the talker publishes:

```bash
ros2 topic hz /chatter
```{{exec}}

About 1 Hz — once per second, just like the talker's log said. `Ctrl+C` when done.
