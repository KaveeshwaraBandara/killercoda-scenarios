# Spawn it and bridge it

Three things have to happen: a **world** must exist, your **robot** must be inserted into it, and the simulator must be **bridged** into ROS 2.

## 1. Start the physics

`-s` = server only (no 3D window, since we have no display), `-r` = run physics immediately:

```bash
gz sim -s -r empty.sdf > /tmp/gz.log 2>&1 &
sleep 8 && echo "world is running"
```{{exec}}

## 2. Insert your robot

```bash
ros2 run ros_gz_sim create -file /work/my_bot_sim.urdf -z 0.3
```{{exec}}

`Entity creation successful` — your robot was dropped into the world 30 cm above the ground. Physics is already running, so it has *fallen*, bounced on its collision shapes, and settled onto its wheels and caster. (If your inertia values were nonsense, this is where it would have exploded.)

## 3. The bridge: where Gazebo meets ROS 2

Here's the architectural surprise: **Gazebo is not a ROS 2 node.** It's a separate program with its own message system. Check — it's true:

```bash
ros2 topic list
```{{exec}}

No `/cmd_vel`, no `/odom`. The simulator is running, and the ROS 2 graph can't see it.

The `ros_gz_bridge` is an interpreter that speaks both protocols:

```bash
ros2 run ros_gz_bridge parameter_bridge \
  /cmd_vel@geometry_msgs/msg/Twist]gz.msgs.Twist \
  /odom@nav_msgs/msg/Odometry[gz.msgs.Odometry > /tmp/bridge.log 2>&1 &
sleep 5 && ros2 topic list
```{{exec}}

Now `/cmd_vel` and `/odom` exist in ROS 2. Read the argument syntax — it's the whole idea in one line:

| Piece | Meaning |
|---|---|
| `/cmd_vel@geometry_msgs/msg/Twist` | the topic, and its **ROS** type |
| `]` | direction: ROS **→** Gazebo (commands go *in*) |
| `[` | direction: Gazebo **→** ROS (odometry comes *out*) |
| `gz.msgs.Twist` | the matching **Gazebo** type |

## The first twitch

`/cmd_vel` carries `geometry_msgs/msg/Twist` — the universal "move the robot" message: `linear.x` in m/s, `angular.z` in rad/s.

Where is the robot right now?

```bash
ros2 topic echo /odom --once --field pose.pose.position
```{{exec}}

`x` is essentially zero. Now push it forward for two seconds:

```bash
timeout 2 ros2 topic pub -r 10 /cmd_vel geometry_msgs/msg/Twist "{linear: {x: 0.5}}"
sleep 1 && ros2 topic echo /odom --once --field pose.pose.position
```{{exec}}

**`x` has grown to about a metre** — and `y` is still ~0, meaning it drove *straight*. Your robot, made of XML you wrote, obeying a message, moving through simulated physics, reporting its own position back.

Try a spin (watch `y` and the orientation change instead):

```bash
timeout 2 ros2 topic pub -r 10 /cmd_vel geometry_msgs/msg/Twist "{angular: {z: 1.0}}"
sleep 1 && ros2 topic echo /odom --once --field pose.pose
```{{exec}}
