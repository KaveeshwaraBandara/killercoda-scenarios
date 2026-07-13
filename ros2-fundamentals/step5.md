# Parameters: tune it live

Every robot has knobs: wheel diameter, max speed, publish rate. Hard-coding them means editing and restarting for every tweak — impossible when you're kneeling next to a robot in a warehouse.

A **parameter** is a named value that belongs to a node but lives on its *surface*: readable and writable from outside, **while the node runs**.

Stop the service server and write a version of the greeter whose message is a knob:

```bash
pkill -f add_server.py
cat > /work/greeter_param.py <<'EOF'
import rclpy
from rclpy.node import Node
from std_msgs.msg import String


class Greeter(Node):
    def __init__(self):
        super().__init__('greeter')
        self.declare_parameter('greeting', 'Greetings, human')  # name + default
        self.declare_parameter('period', 0.5)

        period = self.get_parameter('period').value   # read ONCE at startup
        self.publisher = self.create_publisher(String, 'chatter', 10)
        self.timer = self.create_timer(period, self.speak)
        self.count = 0

    def speak(self):
        greeting = self.get_parameter('greeting').value  # read EVERY time
        msg = String()
        msg.data = f'{greeting} #{self.count}'
        self.publisher.publish(msg)
        self.get_logger().info(f'Published: "{msg.data}"')
        self.count += 1


def main():
    rclpy.init()
    node = Greeter()
    try:
        rclpy.spin(node)
    except KeyboardInterrupt:
        pass
    finally:
        node.destroy_node()


if __name__ == '__main__':
    main()
EOF
echo written
```{{exec}}

## Override at launch

`--ros-args -p name:=value` passes parameters to any ROS 2 node:

```bash
python3 /work/greeter_param.py --ros-args -p greeting:="Ayubowan, robot" -p period:=1.0 > /tmp/g.log 2>&1 &
sleep 3 && tail -n 2 /tmp/g.log
```{{exec}}

## Now change it *while it runs*

```bash
ros2 param list /greeter
```{{exec}}

```bash
ros2 param set /greeter greeting "LIVE TUNING WORKS"
sleep 2 && tail -n 3 /tmp/g.log
```{{exec}}

The running process changed behavior — **no restart, no edit, no redeploy**. That's how real robots get tuned in the field.

Now try the same trick on `period`:

```bash
ros2 param set /greeter period 0.1
sleep 2 && tail -n 3 /tmp/g.log
```{{exec}}

Nothing changes. **Why?** Look back at the code: `period` is read *once at startup* to build the timer, while `greeting` is read on *every* publish. Which values need live re-reading is a design decision — and now you know how to make it.

```bash
pkill -f greeter_param.py; echo "done"
```{{exec}}
