# Describe a robot (URDF)

Gazebo is a big install. Wait for it (this can take a few minutes — it's the price of a physics engine):

```bash
until [ -f /tmp/ros2-ready ]; do echo "…installing ROS 2 + Gazebo, hang tight"; sleep 10; done; echo "✅ ready"
```{{exec}}

Enter the environment (**stay in this container for the whole scenario**):

```bash
docker exec -it ros2 bash
```{{exec}}

## The intuition: links and joints

Squint at any robot and you see **rigid pieces** connected by **things that move**. URDF captures exactly that:

- a **link** is one rigid piece (the chassis, a wheel)
- a **joint** connects a *parent* link to a *child* link and says how the child may move

Our robot is a **differential drive** — two independently driven wheels, like a tank or a Roomba. Same wheel speeds = straight; different = turn. Its tree:

```
base_link (chassis)
 ├── left_wheel   (continuous joint — spins forever)
 ├── right_wheel  (continuous joint)
 └── caster       (fixed joint — just drags)
```

The design rule that generates that tree: **if it moves separately, it's a separate link.**

## Write it

```bash
cat > /work/my_bot.urdf <<'EOF'
<?xml version="1.0"?>
<robot name="my_bot">

  <!-- The chassis: a 40cm x 30cm x 10cm box. All units are METRES. -->
  <link name="base_link">
    <visual>
      <geometry><box size="0.4 0.3 0.1"/></geometry>
      <material name="blue"><color rgba="0.2 0.4 0.9 1.0"/></material>
    </visual>
  </link>

  <!-- Left wheel. rpy rotates the cylinder 90 deg so it lies like a wheel. -->
  <link name="left_wheel">
    <visual>
      <geometry><cylinder radius="0.08" length="0.04"/></geometry>
      <origin rpy="1.5708 0 0"/>
    </visual>
  </link>

  <!-- 'continuous' = rotates without limits, like a real wheel.
       origin = where it attaches (ROS convention: x forward, y LEFT, z up)
       axis   = which way it spins (y = the left-right axis) -->
  <joint name="left_wheel_joint" type="continuous">
    <parent link="base_link"/>
    <child link="left_wheel"/>
    <origin xyz="0 0.17 -0.03"/>
    <axis xyz="0 1 0"/>
  </joint>

  <link name="right_wheel">
    <visual>
      <geometry><cylinder radius="0.08" length="0.04"/></geometry>
      <origin rpy="1.5708 0 0"/>
    </visual>
  </link>

  <joint name="right_wheel_joint" type="continuous">
    <parent link="base_link"/>
    <child link="right_wheel"/>
    <origin xyz="0 -0.17 -0.03"/>
    <axis xyz="0 1 0"/>
  </joint>

  <!-- The caster just holds the front up: 'fixed' = doesn't move at all. -->
  <link name="caster">
    <visual><geometry><sphere radius="0.05"/></geometry></visual>
  </link>

  <joint name="caster_joint" type="fixed">
    <parent link="base_link"/>
    <child link="caster"/>
    <origin xyz="0.15 0 -0.06"/>
  </joint>

</robot>
EOF
echo "robot described"
```{{exec}}

Check that the XML is a valid robot description:

```bash
check_urdf /work/my_bot.urdf 2>/dev/null || python3 -c "
import xml.etree.ElementTree as ET
r = ET.parse('/work/my_bot.urdf').getroot()
links = [l.get('name') for l in r.findall('link')]
joints = [(j.get('name'), j.get('type')) for j in r.findall('joint')]
print('robot:', r.get('name'))
print('links:', links)
print('joints:', joints)
"
```{{exec}}

Four links, three joints — a robot's body, described. It has **no mass yet**, so physics can't touch it. That's next.
