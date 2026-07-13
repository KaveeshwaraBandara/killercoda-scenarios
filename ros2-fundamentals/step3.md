# Write your own publisher

Enough running other people's nodes. Stop the listener and write your own node:

```bash
pkill -f 'demo_nodes_py listener'; echo "listener stopped"
```{{exec}}

Every ROS 2 Python node has the same four beats: **init** → **create a node** → **register intentions** (a timer, a subscription…) → **spin**. Here's a publisher driven by a timer:

```bash
cat > /work/greeter.py <<'EOF'
import rclpy
from rclpy.node import Node
from std_msgs.msg import String


class Greeter(Node):
    def __init__(self):
        super().__init__('greeter')                                   # node name
        self.publisher = self.create_publisher(String, 'chatter', 10) # topic + queue size
        self.timer = self.create_timer(0.5, self.speak)               # call speak() every 0.5 s
        self.count = 0

    def speak(self):
        msg = String()
        msg.data = f'Greetings, human #{self.count}'
        self.publisher.publish(msg)
        self.get_logger().info(f'Published: "{msg.data}"')  # nodes log, they don't print
        self.count += 1


def main():
    rclpy.init()
    node = Greeter()
    try:
        rclpy.spin(node)      # hands control to ROS 2: it fires your timer
    except KeyboardInterrupt:
        pass
    finally:
        node.destroy_node()


if __name__ == '__main__':
    main()
EOF
echo "written to /work/greeter.py"
```{{exec}}

No package, no build system — a node is just a program. Run it in the background:

```bash
python3 /work/greeter.py > /tmp/greeter.log 2>&1 &
```{{exec}}

## Verify it from the outside

Don't trust it — *inspect* it, with the same tools you used on someone else's node:

```bash
ros2 node list && ros2 node info /greeter
```{{exec}}

And the real prize: run the professionals' listener against **your** node.

```bash
ros2 run demo_nodes_py listener
```{{exec}}

`I heard: [Greetings, human #7]` — your code, in the ROS graph, being consumed by software that has never heard of you. Press **Ctrl+C** when you've enjoyed it enough.

**Experiment:** change `0.5` to `0.1` in the file and rerun — then `ros2 topic hz /chatter` will show 10 Hz.
