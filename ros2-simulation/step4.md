# Drive it with your own code

Poking `topic pub` is no way to drive. Anything that publishes `Twist` to `/cmd_vel` can steer this robot — a keyboard, a navigation stack, or **a node you write**. The robot has no idea which.

Here's a driver that traces a square: forward, turn 90°, repeat. It's just a publisher on a timer — the same skeleton as any ROS 2 node — with a two-state machine inside.

```bash
cat > /work/square_driver.py <<'EOF'
import time
import rclpy
from rclpy.node import Node
from rclpy.signals import SignalHandlerOptions
from geometry_msgs.msg import Twist


class SquareDriver(Node):
    """Drives forward 1 m, turns 90 degrees, repeats."""

    EDGE_TIME = 4.0     # 4 s at 0.25 m/s   -> 1 m
    TURN_TIME = 3.1416  # pi s at 0.5 rad/s -> 90 degrees

    def __init__(self):
        super().__init__('square_driver')
        self.publisher = self.create_publisher(Twist, 'cmd_vel', 10)
        self.timer = self.create_timer(0.1, self.step)   # 10 Hz control loop
        self.state = 'forward'
        self.state_time = 0.0

    def step(self):
        self.state_time += 0.1
        cmd = Twist()

        if self.state == 'forward':
            cmd.linear.x = 0.25
            if self.state_time >= self.EDGE_TIME:
                self.switch('turn')
        else:
            cmd.angular.z = 0.5
            if self.state_time >= self.TURN_TIME:
                self.switch('forward')

        self.publisher.publish(cmd)

    def switch(self, new_state):
        self.get_logger().info(f'{self.state} done -> {new_state}')
        self.state = new_state
        self.state_time = 0.0

    def stop_robot(self):
        self.publisher.publish(Twist())   # an all-zero Twist means "stop"


def main():
    # Ctrl+C is OURS to handle. rclpy's default handler would shut the ROS
    # context down before the except block runs — and the stop command would
    # fail with "publisher's context is invalid". The robot would never hear it.
    rclpy.init(signal_handler_options=SignalHandlerOptions.NO)
    node = SquareDriver()
    try:
        rclpy.spin(node)
    except KeyboardInterrupt:
        node.get_logger().info('Ctrl+C — stopping the robot')
        node.stop_robot()
        time.sleep(0.2)      # give the message time to actually go out
    finally:
        node.destroy_node()
        rclpy.shutdown()


if __name__ == '__main__':
    main()
EOF
python3 /work/square_driver.py > /tmp/square.log 2>&1 &
echo "your code is now driving the robot"
```{{exec}}

## Watch it drive

Sample the robot's position every two seconds and watch it trace the square:

```bash
for i in $(seq 1 8); do
  ros2 topic echo /odom --once --field pose.pose.position 2>/dev/null | tr '\n' ' '
  echo
  sleep 2
done
```{{exec}}

Watch the numbers: `x` climbs while `y` holds — driving the first edge. Then `x` stalls while the heading swings — a corner. Then `y` starts climbing — the second edge, at right angles to the first. **Your code is driving a robot around a world.**

See what the driver thinks it's doing:

```bash
tail -n 5 /tmp/square.log
```{{exec}}

## The reality gap, in miniature

Let it run a few laps, then check whether it came home:

```bash
sleep 25 && ros2 topic echo /odom --once --field pose.pose.position
```{{exec}}

It does **not** return exactly to (0, 0). The code commands perfect timing, but physics answers with acceleration lag, wheel slip, and coasting. **Commanding motion is not the same as achieving it.**

This is *dead reckoning drift*, and it's not a bug in your code — it's why real robots close the loop with sensors instead of trusting stopwatches. On a real floor (dust, carpet, a sagging battery) it's far worse — which is exactly what Stage 3 of the course makes you measure.

## The stop that matters

Stop the driver, then ask the robot what it's doing:

```bash
pkill -INT -f square_driver.py
sleep 2 && ros2 topic echo /odom --once --field twist.twist.linear
```{{exec}}

`x: 0.0` — the robot is **stopped**, because the driver published a zero-velocity `Twist` on its way out. Without that, its last instruction would still be *"keep driving"*, and **a robot obeys its last command forever** — your program gone, the robot still rolling.

Look closely at how the code achieves that, because the obvious version *silently fails*: it calls `rclpy.init(signal_handler_options=SignalHandlerOptions.NO)`. Without that, rclpy's own Ctrl+C handler destroys the ROS context **before** your shutdown code runs, and the stop command dies with `publisher's context is invalid` — the robot never hears it.

In simulation that's a curiosity. On real hardware it's the difference between "stopped" and "drove into the wall while you read the traceback".
