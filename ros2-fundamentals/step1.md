# Inspect the graph

Wait for the background setup to finish:

```bash
until [ -f /tmp/ros2-ready ]; do echo "…installing ROS 2, hang tight"; sleep 5; done; echo "✅ ready"
```{{exec}}

Step into the ROS 2 environment (**stay in this container for the whole scenario**):

```bash
docker exec -it ros2 bash
```{{exec}}

Start a **talker** node in the background, so we have a live graph to inspect:

```bash
ros2 run demo_nodes_cpp talker > /tmp/talker.log 2>&1 &
```{{exec}}

## Who is running?

```bash
ros2 node list
```{{exec}}

There's `/talker` — one program, one box in the graph. Now interrogate it:

```bash
ros2 node info /talker
```{{exec}}

Read the output as the node's public face: it **subscribes to nothing** and **publishes to `/chatter`** with type `std_msgs/msg/String`. (`/parameter_events` and `/rosout` appear on *every* node — learn to look past them.)

That's the first debugging superpower: you never have to guess what a program does. You can ask it.
