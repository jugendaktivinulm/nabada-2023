include <components.scad>

cube([4000, 5000, 1], anchor = FRONT + TOP + LEFT) {
	cube_([1000, 1000, 1000], anchor = BOTTOM);
}
