include <BOSL2/std.scad>

exploded = is_undef($exploded) ? 1 : $exploded;
label = is_undef($label) ? 0 : $label;

// assumptions

//beam_width  = 60;
//beam_height = 40;
beam_width  = 50;
beam_height = 30;

plate_thickness = 10; // alternatives: 16, 19

// TODO
//  - emboss sizes on parts
//  - explosion drawings

module beam_x(length, anchor = CENTER, spin = 0, orient = UP) {
	echo("BOM", "Leiste", length);
	recolor(label > 0 ? "red" : "sandybrown")
		cube([length, beam_width, beam_height], anchor = anchor, spin = spin, orient = orient)
			if (label > 1 && length >= 500)
				position(TOP) rotate([$vpr[0], 0, $vpr[2] - spin])
					recolor("white")
						cylinder(d = 400, h = 1)
							recolor("red")
								attach(TOP)
									text3d(str(round(length / 10) / 100, "m"), beam_width/2, 100, anchor = BOTTOM);
}

module beam_y(length, anchor = CENTER, spin = 0, orient = UP) {
	echo("BOM", "Leiste", length);
	recolor(label > 0? "green" : "sandybrown")
		cube([beam_width, length, beam_height], anchor = anchor, spin = spin, orient = orient)
			if (label > 1 && length >= 500)
				position(TOP) rotate([$vpr[0], 0, $vpr[2] - spin])
					recolor("white")
						cylinder(d = 400, h = 1)
							recolor("green")
								text3d(str(round(length / 10) / 100, "m"), beam_width/2, 100, anchor = BOTTOM);
}

module beam_z(length, anchor = CENTER, spin = 0, orient = UP) {
	echo("BOM", "Leiste", length);
	recolor(label > 0 ? "blue" : "sandybrown")
		cube([beam_width, beam_height, length], anchor = anchor, spin = spin, orient = orient)
			if (label > 1 && length >= 500)
				position(FRONT + LEFT) rotate([$vpr[0], 0, $vpr[2] - spin])
					recolor("white")
						cylinder(d = 400, h = 1)
							recolor("blue")
								text3d(str(round(length / 10) / 100, "m"), beam_width/2, 100, anchor = BOTTOM + BACK);
}

module beam_z_(length, anchor = CENTER, spin = 0, orient = UP) {
	echo("BOM", "Leiste", length);
	recolor(label > 0 ? "blue" : "sandybrown")
		cube([beam_height, beam_width, length], anchor = anchor, spin = spin, orient = orient)
			if (label > 1 && length >= 500)
				position(FRONT + LEFT) rotate([$vpr[0], 0, $vpr[2] - spin])
					recolor("white")
						cylinder(d = 400, h = 1)
							recolor("blue")
								text3d(str(round(length / 10) / 100, "m"), beam_width/2, 100, anchor = BOTTOM + BACK);
}

module strut(a, b, anchor = FRONT +  LEFT, spin = 0, orient = UP) {
	length = sqrt(a^2 + b^2);
	alpha = atan(a / b);
	echo("BOM", "Leiste schräg", length, alpha);

	attachable(anchor = anchor, spin = spin, orient = orient, size = [a, b, beam_height]) {
		move([-a/2, -b/2, 0])
			recolor(label > 0 ? "goldenrod" : "sandybrown") diff("remove") {
				xmove(a) zrot(alpha)
					cube([beam_width, length, beam_height - 2], anchor = FRONT + RIGHT, spin = 0, orient = UP)
						if (label > 1 && length >= 500)
							position(TOP + LEFT) rotate([$vpr[0], 0, $vpr[2] - alpha - spin])
								recolor("white")
									cylinder(d = 400, h = 1)
										recolor("goldenrod")
											text3d(str(round(length / 10) / 100, "m"), beam_width/2, 100, anchor = BOTTOM);

				tag("remove") cube([a + 1, beam_width + 1, beam_height + 1], anchor = BACK + LEFT);
				tag("remove") cube([beam_width + 1, b + 1, beam_height + 1], anchor = FRONT + RIGHT);
			}
		children();
	}
}

module screw(l, orient = DOWN) {
	echo("BOM", "Schraube", l);
	attachable(anchor = TOP, spin = 0, orient = orient, r = 10, l = 2) {
		recolor("dimgray")
			cylinder(d1 = 10, d2 = 5, h = 5, anchor = BOTTOM, orient = UP)
				cylinder(d1 = 5, d2 = 3, h = l - 5, anchor = BOTTOM, orient = UP);
		children();
	}
}

module fabric_xy(size, anchor = CENTER, spin = 0, orient = UP) {
	echo("BOM", "Stoff", size);
	color_this([0.5, 0.5, 0.5, 0.5]) cube([size[0], size[1], 1], anchor = anchor, spin = spin, orient = orient);
}

module fabric_xz(size, anchor = CENTER, spin = 0, orient = UP) {
	echo("BOM", "Stoff", size);
	color_this([0.5, 0.5, 0.5, 0.5]) cube([size[0], 1, size[1]], anchor = anchor, spin = spin, orient = orient);
}

module fabric_yz(size, anchor = CENTER, spin = 0, orient = UP, supress_BOM = false) {
	echo("BOM", "Stoff", size);
	color_this([0.5, 0.5, 0.5, 0.5]) cube([1, size[0], size[1]], anchor = anchor, spin = spin, orient = orient);
}

module plate_xy(size, anchor = CENTER, spin = 0, orient = UP) {
	echo("BOM", "Platte", size);
	color_this([1, 0.5, 0.25, 0.5]) cube([size[0], size[1], plate_thickness], anchor = anchor, spin = spin, orient = orient);
}

module plate_xz(size, anchor = CENTER, spin = 0, orient = UP) {
	echo("BOM", "Platte", size);
	color_this([1, 0.5, 0.25, 0.5]) cube([size[0], plate_thickness, size[1]], anchor = anchor, spin = spin, orient = orient);
}

module plate_yz(size, anchor = CENTER, spin = 0, orient = UP, supress_BOM = false) {
	echo("BOM", "Platte", size);
	color_this([1, 0.5, 0.25, 0.5]) cube([plate_thickness, size[0], size[1]], anchor = anchor, spin = spin, orient = orient);
}

COVER_NONE    = [0, 0, 0, 0, 0, 0];

FABRIC_BOTTOM = [1, 0, 0, 0, 0, 0];
FABRIC_TOP    = [0, 1, 0, 0, 0, 0];
FABRIC_FRONT  = [0, 0, 1, 0, 0, 0];
FABRIC_BACK   = [0, 0, 0, 1, 0, 0];
FABRIC_LEFT   = [0, 0, 0, 0, 1, 0];
FABRIC_RIGHT  = [0, 0, 0, 0, 0, 1];
FABRIC_ALL    = FABRIC_BOTTOM + FABRIC_TOP + FABRIC_FRONT + FABRIC_BACK + FABRIC_LEFT + FABRIC_RIGHT;

PLATE_BOTTOM  = [2, 0, 0, 0, 0, 0];
PLATE_TOP     = [0, 2, 0, 0, 0, 0];
PLATE_FRONT   = [0, 0, 2, 0, 0, 0];
PLATE_BACK    = [0, 0, 0, 2, 0, 0];
PLATE_LEFT    = [0, 0, 0, 0, 2, 0];
PLATE_RIGHT   = [0, 0, 0, 0, 0, 2];
PLATE_ALL     = PLATE_BOTTOM + PLATE_TOP + PLATE_FRONT + PLATE_BACK + PLATE_LEFT + PLATE_RIGHT;

function has_fabric_bottom(v) = v[0] == 1 ? true : false;
function has_fabric_top   (v) = v[1] == 1 ? true : false;
function has_fabric_front (v) = v[2] == 1 ? true : false;
function has_fabric_back  (v) = v[3] == 1 ? true : false;
function has_fabric_left  (v) = v[4] == 1 ? true : false;
function has_fabric_right (v) = v[5] == 1 ? true : false;

function has_plate_bottom(v) = v[0] == 2 ? true : false;
function has_plate_top   (v) = v[1] == 2 ? true : false;
function has_plate_front (v) = v[2] == 2 ? true : false;
function has_plate_back  (v) = v[3] == 2 ? true : false;
function has_plate_left  (v) = v[4] == 2 ? true : false;
function has_plate_right (v) = v[5] == 2 ? true : false;

module cube_(size, covers = COVER_NONE, anchor = CENTER, spin = 0, orient = UP, struts = [0, 0, 0]) {
	box = size * exploded;
	attachable(anchor, spin, orient, size = size * (2*exploded - 1)) {
		union() {
			move([-box[0]/2, 0, -box[2]/2]) beam_y(size[1], anchor = BOTTOM + LEFT );
			move([-box[0]/2, 0,  box[2]/2]) beam_y(size[1], anchor = TOP    + LEFT );
			move([ box[0]/2, 0, -box[2]/2]) beam_y(size[1], anchor = BOTTOM + RIGHT);
			move([ box[0]/2, 0,  box[2]/2]) beam_y(size[1], anchor = TOP    + RIGHT);

			move([0, -box[1]/2, -box[2]/2]) beam_x(size[0] - 2*beam_width, anchor = FRONT + BOTTOM);
			move([0, -box[1]/2,  box[2]/2]) beam_x(size[0] - 2*beam_width, anchor = FRONT + TOP   );
			move([0,  box[1]/2, -box[2]/2]) beam_x(size[0] - 2*beam_width, anchor = BACK  + BOTTOM);
			move([0,  box[1]/2,  box[2]/2]) beam_x(size[0] - 2*beam_width, anchor = BACK  + TOP   );

			move([-box[0]/2, -box[1]/2, 0]) beam_z(size[2] - 2*beam_height, anchor = FRONT + LEFT );
			move([-box[0]/2,  box[1]/2, 0]) beam_z(size[2] - 2*beam_height, anchor = BACK  + LEFT );
			move([ box[0]/2, -box[1]/2, 0]) beam_z(size[2] - 2*beam_height, anchor = FRONT + RIGHT);
			move([ box[0]/2,  box[1]/2, 0]) beam_z(size[2] - 2*beam_height, anchor = BACK  + RIGHT);

			if (has_fabric_bottom(covers)) move([0, 0, -box[2]/2]) fabric_xy([size[0], size[1]], anchor = BOTTOM);
			if (has_fabric_top   (covers)) move([0, 0,  box[2]/2]) fabric_xy([size[0], size[1]], anchor = TOP   );
			if (has_fabric_front (covers)) move([0, -box[1]/2, 0]) fabric_xz([size[0], size[2]], anchor = FRONT );
			if (has_fabric_back  (covers)) move([0,  box[1]/2, 0]) fabric_xz([size[0], size[2]], anchor = BACK  );
			if (has_fabric_left  (covers)) move([-box[0]/2, 0, 0]) fabric_yz([size[1], size[2]], anchor = LEFT  );
			if (has_fabric_right (covers)) move([ box[0]/2, 0, 0]) fabric_yz([size[1], size[2]], anchor = RIGHT );

			if (has_plate_bottom(covers)) move([0, 0, -box[2]/2]) plate_xy([size[0], size[1]], anchor = BOTTOM);
			if (has_plate_top   (covers)) move([0, 0,  box[2]/2]) plate_xy([size[0], size[1]], anchor = TOP   );
			if (has_plate_front (covers)) move([0, -box[1]/2, 0]) plate_xz([size[0], size[2]], anchor = FRONT );
			if (has_plate_back  (covers)) move([0,  box[1]/2, 0]) plate_xz([size[0], size[2]], anchor = BACK  );
			if (has_plate_left  (covers)) move([-box[0]/2, 0, 0]) plate_yz([size[1], size[2]], anchor = LEFT  );
			if (has_plate_right (covers)) move([ box[0]/2, 0, 0]) plate_yz([size[1], size[2]], anchor = RIGHT );

			if (struts[0] > 0 && size[1] >= 500 && size[2] >= 500) {
				move([-box[0]/2, -box[1]/2 + beam_height, -box[2]/2 + beam_height]) strut(200, 200, anchor = FRONT + TOP    + LEFT, orient = LEFT, spin =   0);
				move([-box[0]/2, -box[1]/2 + beam_height,  box[2]/2 - beam_height]) strut(200, 200, anchor = FRONT + TOP    + LEFT, orient = LEFT, spin =  90);
				move([-box[0]/2,  box[1]/2 - beam_height,  box[2]/2 - beam_height]) strut(200, 200, anchor = FRONT + TOP    + LEFT, orient = LEFT, spin = 180);
				move([-box[0]/2,  box[1]/2 - beam_height, -box[2]/2 + beam_height]) strut(200, 200, anchor = FRONT + TOP    + LEFT, orient = LEFT, spin = 270);

				move([ box[0]/2, -box[1]/2 + beam_height, -box[2]/2 + beam_height]) strut(200, 200, anchor = FRONT + BOTTOM + LEFT, orient = LEFT, spin =   0);
				move([ box[0]/2, -box[1]/2 + beam_height,  box[2]/2 - beam_height]) strut(200, 200, anchor = FRONT + BOTTOM + LEFT, orient = LEFT, spin =  90);
				move([ box[0]/2,  box[1]/2 - beam_height,  box[2]/2 - beam_height]) strut(200, 200, anchor = FRONT + BOTTOM + LEFT, orient = LEFT, spin = 180);
				move([ box[0]/2,  box[1]/2 - beam_height, -box[2]/2 + beam_height]) strut(200, 200, anchor = FRONT + BOTTOM + LEFT, orient = LEFT, spin = 270);
			}

			if (struts[1] > 0 && size[0] >= 500 && size[2] >= 500) {
				move([-box[0]/2 + beam_width, -box[1]/2, -box[2]/2 + beam_height]) strut(200, 200, anchor = FRONT + TOP    + LEFT, orient = FRONT, spin =   0);
				move([ box[0]/2 - beam_width, -box[1]/2, -box[2]/2 + beam_height]) strut(200, 200, anchor = FRONT + TOP    + LEFT, orient = FRONT, spin =  90);
				move([ box[0]/2 - beam_width, -box[1]/2,  box[2]/2 - beam_height]) strut(200, 200, anchor = FRONT + TOP    + LEFT, orient = FRONT, spin = 180);
				move([-box[0]/2 + beam_width, -box[1]/2,  box[2]/2 - beam_height]) strut(200, 200, anchor = FRONT + TOP    + LEFT, orient = FRONT, spin = 270);

				move([-box[0]/2 + beam_width,  box[1]/2, -box[2]/2 + beam_height]) strut(200, 200, anchor = FRONT + BOTTOM + LEFT, orient = FRONT, spin =   0);
				move([ box[0]/2 - beam_width,  box[1]/2, -box[2]/2 + beam_height]) strut(200, 200, anchor = FRONT + BOTTOM + LEFT, orient = FRONT, spin =  90);
				move([ box[0]/2 - beam_width,  box[1]/2,  box[2]/2 - beam_height]) strut(200, 200, anchor = FRONT + BOTTOM + LEFT, orient = FRONT, spin = 180);
				move([-box[0]/2 + beam_width,  box[1]/2,  box[2]/2 - beam_height]) strut(200, 200, anchor = FRONT + BOTTOM + LEFT, orient = FRONT, spin = 270);
			}

			if (struts[2] > 0 && size[0] >= 500 && size[1] >= 500) {
				move([-box[0]/2 + beam_width, -box[1]/2 + beam_width, -box[2]/2]) strut(200, 200, anchor = FRONT + BOTTOM + LEFT, orient = TOP, spin =   0);
				move([ box[0]/2 - beam_width, -box[1]/2 + beam_width, -box[2]/2]) strut(200, 200, anchor = FRONT + BOTTOM + LEFT, orient = TOP, spin =  90);
				move([ box[0]/2 - beam_width,  box[1]/2 - beam_width, -box[2]/2]) strut(200, 200, anchor = FRONT + BOTTOM + LEFT, orient = TOP, spin = 180);
				move([-box[0]/2 + beam_width,  box[1]/2 - beam_width, -box[2]/2]) strut(200, 200, anchor = FRONT + BOTTOM + LEFT, orient = TOP, spin = 270);

				move([-box[0]/2 + beam_width, -box[1]/2 + beam_width,  box[2]/2]) strut(200, 200, anchor = FRONT + TOP    + LEFT, orient = TOP, spin =   0);
				move([ box[0]/2 - beam_width, -box[1]/2 + beam_width,  box[2]/2]) strut(200, 200, anchor = FRONT + TOP    + LEFT, orient = TOP, spin =  90);
				move([ box[0]/2 - beam_width,  box[1]/2 - beam_width,  box[2]/2]) strut(200, 200, anchor = FRONT + TOP    + LEFT, orient = TOP, spin = 180);
				move([-box[0]/2 + beam_width,  box[1]/2 - beam_width,  box[2]/2]) strut(200, 200, anchor = FRONT + TOP    + LEFT, orient = TOP, spin = 270);
			}
		}
		children();
	}
}

module fabric_xy_diag(size, anchor = CENTER, spin = 0, orient = UP) {
	echo("BOM", "Stoff dreieckig", size);
	diag = sqrt(size[0]^2 + size[1]^2);
	alpha = atan(size[1] / size[0]);
	color_this([0.5, 0.5, 0.5, 0.5])
		diff("remove")
			cube([size[0], size[1], 1], anchor = anchor, spin = spin, orient = orient)
				tag("remove") cube([diag, diag, 3], anchor = LEFT, spin = 90 - alpha);
}

module plate_xy_diag(size, anchor = CENTER, spin = 0, orient = UP) {
	echo("BOM", "Platte dreieckig", size);
	diag = sqrt(size[0]^2 + size[1]^2);
	alpha = atan(size[1] / size[0]);
	color_this([1, 0.5, 0.25, 0.5])
		diff("remove")
			cube([size[0], size[1], plate_thickness], anchor = anchor, spin = spin, orient = orient)
				tag("remove") cube([diag, diag, plate_thickness + 2], anchor = LEFT, spin = 90 - alpha);
}

module prism_(size, covers = COVER_NONE, anchor = CENTER, spin = 0, orient = UP) {
	box = size * exploded;
	attachable(anchor, spin, orient, size = size * (2*exploded - 1)) {
		union() {
			move([-box[0]/2, beam_height/4, -box[2]/2]) beam_y(size[1] - beam_width - beam_height, anchor = BOTTOM + LEFT );
			move([-box[0]/2, beam_height/4,  box[2]/2]) beam_y(size[1] - beam_width - beam_height, anchor = TOP    + LEFT );

			move([0, -box[1]/2, -box[2]/2]) beam_x(size[0], anchor = FRONT + BOTTOM);
			move([0, -box[1]/2,  box[2]/2]) beam_x(size[0], anchor = FRONT + TOP   );

			move([-box[0]/2, -box[1]/2, 0]) beam_z_(size[2] - 2*beam_height, anchor = FRONT + LEFT );
			move([-box[0]/2,  box[1]/2, 0]) beam_z (size[2]                , anchor = BACK  + LEFT );
			move([ box[0]/2, -box[1]/2, 0]) beam_z_(size[2] - 2*beam_height, anchor = FRONT + RIGHT);

			move([box[0]/2, box[1]/2, -box[2]/2]) strut(size[0] - beam_width, size[1] - beam_width, anchor = BOTTOM + BACK + RIGHT);
			move([box[0]/2, box[1]/2,  box[2]/2]) strut(size[0] - beam_width, size[1] - beam_width, anchor = TOP    + BACK + RIGHT);

			diag  = sqrt((size[0] - beam_width)^2 + (size[1] - beam_width)^2);
			alpha = atan((size[0] - beam_width)/(size[1] - beam_width));
			dispx = diag * (exploded - 1)/2 * cos(alpha);
			dispy = diag * (exploded - 1)/2 * sin(alpha);

			if (has_fabric_bottom(covers)) move([0, 0, -box[2]/2]) fabric_xy_diag([size[0], size[1]], anchor = BOTTOM);
			if (has_fabric_top   (covers)) move([0, 0,  box[2]/2]) fabric_xy_diag([size[0], size[1]], anchor = TOP   );
			if (has_fabric_front (covers)) move([0, -box[1]/2, 0]) fabric_xz     ([size[0], size[2]], anchor = FRONT );
			if (has_fabric_left  (covers)) move([-box[0]/2, 0, 0]) fabric_yz     ([size[1], size[2]], anchor = LEFT  );

			if (has_fabric_right(covers) || has_fabric_back(covers))
				move([beam_width/2 + dispx, beam_width/2 + dispy, 0]) fabric_yz([diag, size[2]],anchor = RIGHT, spin = alpha);

			if (has_plate_bottom(covers)) move([0, 0, -box[2]/2]) plate_xy_diag([size[0], size[1]], anchor = BOTTOM);
			if (has_plate_top   (covers)) move([0, 0,  box[2]/2]) plate_xy_diag([size[0], size[1]], anchor = TOP   );
			if (has_plate_front (covers)) move([0, -box[1]/2, 0]) plate_xz     ([size[0], size[2]], anchor = FRONT );
			if (has_plate_left  (covers)) move([-box[0]/2, 0, 0]) plate_yz     ([size[1], size[2]], anchor = LEFT  );

			if (has_plate_right(covers) || has_plate_back(covers))
				move([beam_width/2 + dispx, beam_width/2 + dispy, 0]) plate_yz([diag, size[2]],anchor = RIGHT, spin = alpha);
		}
		children();
	}
}
