include <assemblies.scad>

cube([4000, 5000, 1], anchor = TOP + FRONT) {
	position(FRONT + TOP + RIGHT) wallr();
	position(FRONT + TOP + LEFT ) walll();
	position(FRONT) ymove(1000) bridge();
	position(BACK) ymove(-500) turret_base(BOTTOM + BACK) {
		position(TOP) turret_top(BOTTOM);
	}
}
