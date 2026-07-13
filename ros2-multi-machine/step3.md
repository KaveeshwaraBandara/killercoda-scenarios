# The robot side: a motor driver

On a real robot, a **motor driver node** runs on the Pi. Its whole job:

> subscribe to `/cmd_vel` → convert the requested robot motion into **left and right wheel speeds** → send those to the motor hardware.

That conversion is *differential-drive kinematics*, and it's two lines of arithmetic. Given the robot's linear velocity `v` (m/s), angular velocity `ω` (rad/s), wheel separation `L`, and wheel radius `r`:

```
left_wheel_speed  = (v - ω·L/2) / r        # rad/s
right_wheel_speed = (v + ω·L/2) / r
```

Straight ahead (ω = 0) → both wheels equal. Spinning in place (v = 0) → wheels equal and *opposite*. That's the entire theory of tank steering.

Write the driver on the **robot** machine — the only line we can't run here is the last one, which would talk to real motor hardware:

```bash
cat > /root/work/motor_driver.py <<'EOF'
import rclpy
from rclpy.node import Node
from geometry_msgs.msg import Twist


class MotorDriver(Node):
    """Subscribes to /cmd_vel and turns it into wheel speeds.
    This is the node that would run on the robot's Raspberry Pi."""

    WHEEL_SEPARATION = 0.34   # metres between the two wheels
    WHEEL_RADIUS = 0.08       # metres

    def __init__(self):
        super().__init__('motor_driver')
        self.create_subscription(Twist, 'cmd_vel', self.on_cmd, 10)
        self.get_logger().info('Motor driver ready — waiting for /cmd_vel')

    def on_cmd(self, msg):
        v = msg.linear.x       # m/s forward
        w = msg.angular.z      # rad/s turn

        left = (v - w * self.WHEEL_SEPARATION / 2.0) / self.WHEEL_RADIUS
        right = (v + w * self.WHEEL_SEPARATION / 2.0) / self.WHEEL_RADIUS

        # On real hardware, the next line would be something like:
        #   self.hardware.set_wheel_speeds(left, right)
        self.get_logger().info(
            f'cmd_vel(v={v:+.2f} w={w:+.2f})  ->  wheels(L={left:+6.2f} R={right:+6.2f}) rad/s')


def main():
    rclpy.init()
    node = MotorDriver()
    try:
        rclpy.spin(node)
    except KeyboardInterrupt:
        pass
    finally:
        node.destroy_node()


if __name__ == '__main__':
    main()
EOF
echo "motor_driver.py written"
```{{exec}}

Start it on the robot:

```bash
docker exec -d robot bash -lc "python3 /work/motor_driver.py > /tmp/motor.log 2>&1"
sleep 3 && docker exec robot bash -lc "cat /tmp/motor.log"
```{{exec}}

## Test it from the laptop, by hand

Before trusting any code, drive the "robot" manually — this is the software equivalent of the **wheels-up test** every roboticist does before letting a robot touch the floor:

```bash
docker exec laptop bash -lc "ros2 topic pub --once /cmd_vel geometry_msgs/msg/Twist '{linear: {x: 0.5}}'"
sleep 1 && docker exec robot bash -lc "tail -n 1 /tmp/motor.log"
```{{exec}}

Both wheels `+6.25 rad/s` — equal, so it drives **straight**. Now a pure spin:

```bash
docker exec laptop bash -lc "ros2 topic pub --once /cmd_vel geometry_msgs/msg/Twist '{angular: {z: 1.0}}'"
sleep 1 && docker exec robot bash -lc "tail -n 1 /tmp/motor.log"
```{{exec}}

Wheels **equal and opposite** (`L=-2.12`, `R=+2.12`) — the robot turns in place. The kinematics work, the network works, and a command typed on one machine became wheel speeds on another.
