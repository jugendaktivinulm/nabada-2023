include <components.scad>
include <waende.scad>

cube([4000, 5000, 1], anchor = FRONT + TOP + LEFT) {
	//cube_([1000, 1000, 1000], anchor = BOTTOM);
    move([0,750,0])cube_([2000,1500,2500],anchor=BOTTOM){
        translate([0,0,-250]){
            move([1000,0,0])beam_y(1500-2*beam_height, anchor=RIGHT+BOTTOM);
            move([-1000,0,0])beam_y(1500-2*beam_height, anchor=LEFT+BOTTOM);
            move([0,-750,0])beam_x(2000-2*beam_width, anchor=FRONT+BOTTOM);
            move([0,750,0])beam_x(2000-2*beam_width, anchor=BACK+BOTTOM);
            move([0,750,0])plate_xz([2000,1500],anchor=BOTTOM+BACK);
            move([1000,0,0])plate_yz([1500,1500],anchor=BOTTOM+RIGHT);
            move([-1000,0,0])plate_yz([1500,1500],anchor=BOTTOM+LEFT);
            move([0,-1000,750])prism_([1500,500,2000],orient=LEFT,spin=180,covers=PLATE_BACK + PLATE_TOP + PLATE_BOTTOM);
        }
        move([0,750,1250])plate_xy([2500,2250],anchor=BACK+BOTTOM);
        move([0,750-beam_width,-1250])beam_z(3800,anchor=BOTTOM+BACK);
        move([0,750-beam_width+1500,1650])plate_yz([1500,900],anchor=BOTTOM+BACK,supress_BOM=true);
    }
    
}
translate([-10,0,0]){
    color("white")cube([10,5000,300]);
    translate([0,4700,50])rotate([0,0,-90])rotate([90,0,0])text("16     |    Europa Grenzenlos    |    16", size=200);
}
color("navy"){
    wand2();
    translate([4000,0,0])mirror([1,0,0])wand2();
}

//translate([500,2000,0])cube_([3000, 2000, 1000], anchor=FRONT+BOTTOM+LEFT);



/*color("white"){
    translate([1000,2000,1000]){
        polyhedron([[100,500,0],[1900,500,0],[1900,2000,0],[100,2000,0],[0,0,1500],[2000,0,1500],[2000,2000,1500],[0,2000,1500]],[[0,1,2,3],[1,0,4,5],[2,1,5,6],[3,2,6,7],[0,3,7,4],[7,6,5,4]]);
        translate([-250,-250,1500])cube([2500,2250,10]);
        translate([1000-375,1000,1510])polyhedron([[0,0,0],[750,0,0],[750,750,0],[0,750,0],[125,500,1000],[625,500,1000],[625,1000,1000],[125,1000,1000]],[[0,1,2,3],[1,0,4,5],[2,1,5,6],[3,2,6,7],[0,3,7,4],[7,6,5,4]]);
    }
}*/

//translate([40,3000,600])rotate([0,-atan(0.3),0])rotate([0,0,-90])rotate([90,0,0])text("Coast Guard", size = 150);