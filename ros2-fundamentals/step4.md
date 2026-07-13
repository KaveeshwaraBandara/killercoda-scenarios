# Services: ask and answer

Topics are a firehose — great for sensor streams, wrong for questions. When a node needs **one specific answer** ("add these numbers", "reset odometry"), that's a **service**.

Stop your greeter:

```bash
pkill -f greeter.py; echo "greeter stopped"
```{{exec}}

## The shape of a service

```bash
ros2 interface show example_interfaces/srv/AddTwoInts
```{{exec}}

```
int64 a
int64 b
---
int64 sum
```

The `---` splits the **request** (what you send) from the **response** (what you get back). Every service type has these two halves — that's the whole difference from a topic message.

## Write the server

```bash
cat > /work/add_server.py <<'EOF'
import rclpy
from rclpy.node import Node
from example_interfaces.srv import AddTwoInts   # note: .srv, not .msg


class AddServer(Node):
    def __init__(self):
        super().__init__('my_add_server')
        self.service = self.create_service(
            AddTwoInts,        # type (request + response)
            'add_two_ints',    # service name
            self.on_request)   # runs once per incoming request

    def on_request(self, request, response):
        response.sum = request.a + request.b
        self.get_logger().info(
            f'Answered: {request.a} + {request.b} = {response.sum}')
        return response        # returning it is what sends it back!


def main():
    rclpy.init()
    node = AddServer()
    try:
        rclpy.spin(node)
    except KeyboardInterrupt:
        pass
    finally:
        node.destroy_node()


if __name__ == '__main__':
    main()
EOF
python3 /work/add_server.py > /tmp/server.log 2>&1 &
echo "server running"
```{{exec}}

## Call it

Servers wait silently. Discover and call yours exactly the way you'd call anyone's:

```bash
ros2 service list | grep add
```{{exec}}

```bash
ros2 service call /add_two_ints example_interfaces/srv/AddTwoInts "{a: 41, b: 1}"
```{{exec}}

```
response:
example_interfaces.srv.AddTwoInts_Response(sum=42)
```

One question, one answer, done — no stream, no loop. And your server logged the request:

```bash
tail -n 2 /tmp/server.log
```{{exec}}

**The rule to remember:** *Topics for streams. Services for questions.* If the sender needs an answer → service.
