# ROS_DOMAIN_ID: the isolation switch

Imagine a classroom where six students each bring a robot onto one WiFi network. Without isolation, every laptop would see every robot's nodes — and `/cmd_vel` would drive **all six robots at once**.

`ROS_DOMAIN_ID` (a number, 0–101) partitions the network. Machines sharing an ID see each other; machines with different IDs are invisible to one another. Default is `0`, which is why everything has "just worked" so far.

## Break it on purpose

Ask the laptop to look for nodes — but on domain **42**, while the robot's talker is still on the default domain 0:

```bash
docker exec laptop bash -lc "export ROS_DOMAIN_ID=42 && ros2 node list"
```{{exec}}

Empty. The talker is *still running* on the robot — the laptop simply cannot see it. **Memorize this feeling.** A silent, empty `ros2 node list` when you *know* a node is running is the single most common robot bring-up bug, and mismatched domain IDs cause most of them.

## Fix it properly: both machines, same domain

The rule: set it on **both** machines, in every shell they use — which is why on a real robot it belongs in `~/.bashrc`. (Here we append it to the shell profile both containers load.)

```bash
for M in robot laptop; do
  docker exec $M bash -c "echo 'export ROS_DOMAIN_ID=42' >> /etc/profile.d/ros2.sh"
done
echo "both machines are now on domain 42"
```{{exec}}

Restart the talker on the robot so it picks up the new domain, then look again from the laptop:

```bash
docker exec robot bash -lc "pkill -f 'demo_nodes_cpp talker'"
docker exec -d robot bash -lc "ros2 run demo_nodes_cpp talker > /tmp/talker.log 2>&1"
sleep 3
docker exec laptop bash -lc "ros2 node list"
```{{exec}}

`/talker` is back — both machines are speaking on domain 42, invisible to any other robot on the same WiFi.

Stop the talker; the rest of the scenario is about driving:

```bash
docker exec robot bash -lc "pkill -f 'demo_nodes_cpp talker'"; echo stopped
```{{exec}}

??? Troubleshooting on real hardware
When your laptop can't see your Pi: check `echo $ROS_DOMAIN_ID` on **both**, in the exact terminals you're using; make sure neither has `ROS_LOCALHOST_ONLY=1` set; and confirm both are on the *same* network (guest WiFi and phone hotspots often block the discovery traffic between clients).
