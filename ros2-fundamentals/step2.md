# Topics: watch, measure, inject

The talker is still publishing. What exactly is it publishing?

```bash
ros2 topic info /chatter
```{{exec}}

One publisher, zero subscribers, type `std_msgs/msg/String`. What's *inside* that type?

```bash
ros2 interface show std_msgs/msg/String
```{{exec}}

A single field, `data`. Now watch the live traffic — press **Ctrl+C** after a few messages:

```bash
ros2 topic echo /chatter
```{{exec}}

And measure its rate (**Ctrl+C** to stop):

```bash
ros2 topic hz /chatter
```{{exec}}

About 1 Hz. On a real robot, `hz` is the first thing you check when "the camera feels laggy".

## Now become the publisher

Here's the payoff of *decoupling*: subscribers don't know or care who publishes. Kill the talker and take its place.

```bash
pkill -f 'demo_nodes_cpp talker'; echo "talker stopped"
```{{exec}}

Start a **listener** in the background — it's now subscribing to a topic with nobody publishing to it:

```bash
ros2 run demo_nodes_py listener > /tmp/listener.log 2>&1 &
```{{exec}}

Publish to `/chatter` **by hand**, and let it run for a few seconds before pressing **Ctrl+C**:

```bash
ros2 topic pub /chatter std_msgs/msg/String "{data: 'I am the talker now'}"
```{{exec}}

Did the listener hear you?

```bash
tail -n 5 /tmp/listener.log
```{{exec}}

`I heard: [I am the talker now]` — a node written by professionals, obeying messages typed by you. It cannot tell the difference. This is exactly why simulated robots and real robots can run the same code.
