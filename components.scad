include <BOSL2/std.scad>

// assumptions

beam_width  = 60;
beam_height = 40;

plate_thickness = 10; // alternatives: 16, 19

angle_length    = 60;
angle_width     = 30;
angle_thickness = 3;

// TODO:
//  - emboss sizes on parts
//  - screws
//  - explosion drawings
//  - covered cube/prism size correction
//  - diagonal prism beams
//  - diagonal prism plates

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

module screw(l, orient = DOWN) {
	echo("BOM", "Schraube", l);
	attachable(anchor = TOP, spin = 0, orient = orient, r = 10, l = 2) {
		recolor("dimgray")
			cylinder(d1 = 10, d2 = 5, h = 5, anchor = BOTTOM, orient = UP)
				cylinder(d1 = 5, d2 = 3, h = l - 5, anchor = BOTTOM, orient = UP);
		children();
	}
}
/*
module angle(spin = 0, orient = UP, anchor = CENTER) {
	echo("BOM", "Winkel");
	attachable(anchor = BACK + DOWN + anchor, spin = spin, orient = orient, size = [angle_width, angle_length, angle_length]) {
		diff() {
			recolor("gold")
				cube([angle_width, angle_length, angle_length], center = true)
					tag("keep") {
						attach(BOTTOM) {
							move([-angle_width/4, -angle_length/4, -angle_thickness]) screw(beam_height - 5, orient = UP);
							move([ angle_width/4,  angle_length/4, -angle_thickness]) screw(beam_height - 5, orient = UP);
						}
						attach(BACK) {
							move([-angle_width/4, -angle_length/4, -angle_thickness]) screw(beam_height - 5, orient = UP);
							move([ angle_width/4,  angle_length/4, -angle_thickness]) screw(beam_height - 5, orient = UP);
						}
					}

			tag("remove")
				move([0, -angle_thickness, angle_thickness])
					cube([angle_width + 2, angle_length, angle_length], center = true);
		}
		children();
	}
}
*/

module plate_xy(size, anchor = CENTER, spin = 0, orient = UP) {
	echo("BOM", "Platte", size);
	% cube([size[0], size[1], plate_thickness], anchor = anchor, spin = spin, orient = orient);
}

module plate_xz(size, anchor = CENTER, spin = 0, orient = UP) {
	echo("BOM", "Platte", size);
	% cube([size[0], plate_thickness, size[1]], anchor = anchor, spin = spin, orient = orient);
}

module plate_yz(size, anchor = CENTER, spin = 0, orient = UP, supress_BOM = false) {
	if(supress_BOM == false) echo("BOM", "Platte", size);
	% cube([plate_thickness, size[0], size[1]], anchor = anchor, spin = spin, orient = orient);
}

PLATE_NONE   = [0, 0, 0, 0, 0, 0];
PLATE_BOTTOM = [1, 0, 0, 0, 0, 0];
PLATE_TOP    = [0, 1, 0, 0, 0, 0];
PLATE_FRONT  = [0, 0, 1, 0, 0, 0];
PLATE_BACK   = [0, 0, 0, 1, 0, 0];
PLATE_LEFT   = [0, 0, 0, 0, 1, 0];
PLATE_RIGHT  = [0, 0, 0, 0, 0, 1];
PLATE_ALL    = PLATE_BOTTOM + PLATE_TOP + PLATE_FRONT + PLATE_BACK + PLATE_LEFT + PLATE_RIGHT;

function has_plate_bottom(v) = v[0] > 0 ? true : false;
function has_plate_top   (v) = v[1] > 0 ? true : false;
function has_plate_front (v) = v[2] > 0 ? true : false;
function has_plate_back  (v) = v[3] > 0 ? true : false;
function has_plate_left  (v) = v[4] > 0 ? true : false;
function has_plate_right (v) = v[5] > 0 ? true : false;

module cube_(size, covers = PLATE_NONE, anchor = CENTER, spin = 0, orient = UP) {
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

			if (has_plate_bottom(covers)) move([0, 0, -size[2]/2]) plate_xy([size[0], size[1]], anchor = BOTTOM);
			if (has_plate_top   (covers)) move([0, 0,  size[2]/2]) plate_xy([size[0], size[1]], anchor = TOP   );
			if (has_plate_front (covers)) move([0, -size[1]/2, 0]) plate_xz([size[0], size[2]], anchor = FRONT );
			if (has_plate_back  (covers)) move([0,  size[1]/2, 0]) plate_xz([size[0], size[2]], anchor = BACK  );
			if (has_plate_left  (covers)) move([-size[0]/2, 0, 0]) plate_yz([size[1], size[2]], anchor = LEFT  );
			if (has_plate_right (covers)) move([ size[0]/2, 0, 0]) plate_yz([size[1], size[2]], anchor = RIGHT );
		}
		children();
	}
}

module prism_(size, covers = PLATE_NONE, anchor = CENTER, spin = 0, orient = UP) {
	attachable(anchor, spin, orient, size = size) {
		union() {
			move([-size[0]/2, beam_height/4, -size[2]/2]) beam_y(size[1] - beam_width - beam_height, anchor = BOTTOM + LEFT );
			move([-size[0]/2, beam_height/4,  size[2]/2]) beam_y(size[1] - beam_width - beam_height, anchor = TOP    + LEFT );

			move([0, -size[1]/2, -size[2]/2]) beam_x(size[0], anchor = FRONT + BOTTOM);
			move([0, -size[1]/2,  size[2]/2]) beam_x(size[0], anchor = FRONT + TOP   );

			move([-size[0]/2, -size[1]/2, 0]) beam_z(size[2] - 2*beam_height, anchor = FRONT + LEFT );
			move([-size[0]/2,  size[1]/2, 0]) beam_z(size[2], anchor = BACK  + LEFT );
			move([ size[0]/2, -size[1]/2, 0]) beam_z(size[2] - 2*beam_height, anchor = FRONT + RIGHT);
            
            diag = sqrt((size[0] - beam_width)^2 + (size[1] - beam_width)^2);
            alpha = atan((size[0] - beam_width)/(size[1] - beam_width));
            
            move([beam_width/2 , beam_width/2 , -size[2]/2]) beam_y(diag, anchor = BOTTOM + RIGHT,spin=alpha);
            move([beam_width/2 , beam_width/2 ,  size[2]/2]) beam_y(diag, anchor = TOP    + RIGHT,spin=alpha);

			if (has_plate_front (covers)) move([0, -size[1]/2, 0]) plate_xz([size[0], size[2]], anchor = FRONT );
			if (has_plate_left  (covers)) move([-size[0]/2, 0, 0]) plate_yz([size[1], size[2]], anchor = LEFT  );
            if (has_plate_right(covers) || has_plate_back(covers)) move([beam_width/2,beam_width/2,0]) plate_yz([diag,size[2]],anchor=RIGHT,spin=alpha);
            if (has_plate_right(covers)) move([size[0]/2,-size[1]/2,0])plate_yz([beam_width,size[2]], anchor = RIGHT+FRONT);
            
            /*if (has_plate_top (covers)) move([0,0,size[2]/2]) difference(){
                plate_xy([size[0],size[1]], anchor=TOP);
                move([size[0]-beam_width/4,4*beam_width,0]) plate_xy([size[0],diag], spin=alpha, anchor=RIGHT+TOP);
            }*/
		}
		children();
	}
}
