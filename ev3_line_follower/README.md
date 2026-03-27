# EV3 3-Sensor Line Follower

## Overview

A competition-quality, PD-controlled line follower for the LEGO Mindstorms EV3.
Uses three colour sensors in a triangular formation for fast, stable black-line tracking.

---

## Hardware wiring

| Component               | EV3 Port |
|-------------------------|----------|
| Colour sensor – **left**   | Input **1** |
| Colour sensor – **middle** | Input **2** |
| Colour sensor – **right**  | Input **3** |
| Large motor – **left**     | Output **C** |
| Large motor – **right**    | Output **B** |

All sensors must be set to **Reflected Light Intensity** mode (handled in code).

---

## How to run

1. Copy `line_follower.py` to your EV3 brick (e.g. via SSH or `brickrun`).
2. Make sure **ev3dev2** is installed (`pip3 install python-ev3dev2`).
3. Run: `python3 line_follower.py`
4. Press any button on the brick to **start**.
5. Press any button again to **stop**.

---

## Control strategy

```
norm = (raw – BLACK_VALUE) / (WHITE_VALUE – BLACK_VALUE)   clamped to [0, 1]

error      = 0.5 – norm_middle          # 0 when on line edge; + = drifted right
d_error    = error – prev_error
correction = Kp * error + Kd * d_error

if left_sensor on line  → correction += SIDE_BOOST   (extra left steer)
if right_sensor on line → correction -= SIDE_BOOST   (extra right steer)

left_speed  = BASE_SPEED – correction
right_speed = BASE_SPEED + correction
```

**Lost-line recovery**: if all three sensors see white, the robot pivots in
the direction of the last known error until any sensor re-acquires the line.

---

## Tuning guide

### The robot zig-zags or oscillates

The derivative term or proportional gain is too high.

- **First**: decrease `Kp` by 5–10 at a time (e.g. 55 → 45).
- **If still oscillating**: increase `Kd` by 1–2 (e.g. 8 → 10) to add more damping.
- **As a last resort**: increase `LOOP_DELAY` slightly (e.g. 0.01 → 0.015) to
  slow the control frequency.

### The robot is too slow

- Increase `BASE_SPEED` (e.g. 40 → 55).
- If it starts to oscillate at higher speed, increase `Kd` proportionally.

### The robot loses the line too often

Possible causes: corners too sharp, insufficient side-sensor reaction, or
calibration mismatch.

- Increase `SIDE_BOOST` (e.g. 30 → 45) so side sensors react stronger.
- Decrease `LOST_SPEED` (e.g. 20 → 12) so the recovery pivot is slower and
  more thorough.
- Re-check `BLACK_VALUE` / `WHITE_VALUE`: hold each sensor over black/white,
  read the raw value, and update the constants accordingly.

### General calibration tips

| Constant       | Typical value | Effect of increasing            |
|----------------|---------------|----------------------------------|
| `BLACK_VALUE`  | 5 – 15        | Reduces sensitivity on black     |
| `WHITE_VALUE`  | 75 – 90       | Reduces sensitivity on white     |
| `BASE_SPEED`   | 30 – 70       | Faster overall                   |
| `Kp`           | 30 – 80       | Sharper turns, more oscillation  |
| `Kd`           | 5 – 20        | More damping, smoother path      |
| `SIDE_BOOST`   | 20 – 50       | Stronger edge-guard correction   |
| `LOST_SPEED`   | 10 – 30       | Faster recovery pivot            |

Start with the defaults, verify on a straight line, then on curves.
Adjust one parameter at a time and test after each change.
