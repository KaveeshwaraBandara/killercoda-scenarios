# Two machines, one graph

Wait for both machines to finish provisioning:

```bash
until [ -f /tmp/ros2-ready ]; do echo "…preparing robot + laptop, hang tight"; sleep 5; done; echo "✅ both machines ready"
```{{exec}}

You now have two containers acting as two computers:

| Container | Stands for | In real life |
|---|---|---|
| `robot` | the Raspberry Pi bolted to the chassis | runs motor drivers, sensor nodes |
| `laptop` | your development machine | runs teleop, RViz, your code |

## Start a node on the robot

```bash
docker exec -d robot bash -lc "ros2 run demo_nodes_cpp talker > /tmp/talker.log 2>&1"
echo "talker started on the ROBOT"
```{{exec}}

## Look for it from the laptop

Nothing was configured to connect these machines. Ask the laptop what it can see:

```bash
docker exec laptop bash -lc "ros2 node list"
```{{exec}}

```
/talker
```

**A node running on a different machine, listed on this one.** Nobody typed an IP address. ROS 2's discovery found it on the network automatically — the same mechanism that connected your terminals in Stage 0, now crossing machines.

Prove the data really flows, not just the name:

```bash
docker exec laptop bash -lc "timeout 6 ros2 topic echo /chatter"
```{{exec}}

Messages generated on the robot, printed on the laptop. That's the entire networking setup for a ROS 2 robot: **put both machines on the same network.** There is no step two.

…well, there's *one* switch. Next step, meet the thing that will bite you.
