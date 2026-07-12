# Enter the ROS 2 environment

First, wait for the background setup to finish (usually well under a minute):

```bash
until [ -f /tmp/ros2-ready ]; do echo "…installing ROS 2, hang tight"; sleep 5; done; echo "✅ ROS 2 is ready!"
```{{exec}}

ROS 2 lives in a container on this machine (the same environment the course uses everywhere). Step inside it:

```bash
docker exec -it ros2 bash
```{{exec}}

Your prompt changes — you're now in a shell where the `ros2` command works. Prove it:

```bash
ros2 --help
```{{exec}}

If you see the list of ros2 commands, you're in. On to the fun part.
