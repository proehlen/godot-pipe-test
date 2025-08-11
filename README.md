# Godot (4.4.1) IPC with Pipes test 

This is just a quick throwaway project to experiment with and test Godot IPC with a subprocess via pipes.

The script `echo-test.sh` is a small bash echo server that is launched by Godot and can be communicated with via the main scene.

**NOTE:** I'm not sure I've covered every edge case yet and I'm all but ignoring stderr so you copy this code at your own risk.
