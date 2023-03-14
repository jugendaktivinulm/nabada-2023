include <BOSL2/std.scad>

beam_width  = 30;
beam_height = 20;

module beam_x(length, anchor = CENTER, spin = 0, orient = UP) {
	echo("BOM", "Leiste", length);
	recolor("sandybrown") cube([length, beam_width, beam_height], anchor = anchor, spin = spin, orient = orient);
}

module beam_y(length, anchor = CENTER, spin = 0, orient = UP) {
	echo("BOM", "Leiste", length);
	recolor("sandybrown") cube([beam_width, length, beam_height], anchor = anchor, spin = spin, orient = orient);
}

module beam_z(length, anchor = CENTER, spin = 0, orient = UP) {
	echo("BOM", "Leiste", length);
	recolor("sandybrown") cube([beam_width, beam_height, length], anchor = anchor, spin = spin, orient = orient);
}

module cube_(size, anchor = CENTER, spin = 0, orient = UP) {
	attachable(anchor, spin, orient, size = size) {
		union() {
			move([-size[0]/2, 0, -size[2]/2]) beam_y(size[1], anchor = BOTTOM + LEFT );
			move([-size[0]/2, 0,  size[2]/2]) beam_y(size[1], anchor = TOP    + LEFT );
			move([ size[0]/2, 0, -size[2]/2]) beam_y(size[1], anchor = BOTTOM + RIGHT);
			move([ size[0]/2, 0,  size[2]/2]) beam_y(size[1], anchor = TOP    + RIGHT);

			move([0, -size[1]/2, -size[2]/2]) beam_x(size[0] - 2*beam_width, anchor = FRONT + BOTTOM);
			move([0, -size[1]/2,  size[2]/2]) beam_x(size[0] - 2*beam_width, anchor = FRONT + TOP   );
			move([0,  size[1]/2, -size[2]/2]) beam_x(size[0] - 2*beam_width, anchor = BACK  + BOTTOM);
			move([0,  size[1]/2,  size[2]/2]) beam_x(size[0] - 2*beam_width, anchor = BACK  + TOP   );

			move([-size[0]/2, -size[1]/2, 0]) beam_z(size[2] - 2*beam_height, anchor = FRONT + LEFT );
			move([-size[0]/2,  size[1]/2, 0]) beam_z(size[2] - 2*beam_height, anchor = BACK  + LEFT );
			move([ size[0]/2, -size[1]/2, 0]) beam_z(size[2] - 2*beam_height, anchor = FRONT + RIGHT);
			move([ size[0]/2,  size[1]/2, 0]) beam_z(size[2] - 2*beam_height, anchor = BACK  + RIGHT);
		}
		children();
	}
	for (i = [1:12]) {
		echo("BOM", "Winkel");
		for (i = [1:4]) echo("BOM", "Schraube");
	}

}
