include <components.scad>
include <waende.scad>

cube([4000, 5000, 1], anchor = FRONT + TOP + LEFT) {
	cube_([1000, 1000, 1000], anchor = BOTTOM);
    
}

color("white")cube([10,5000,300]);
translate([0,4700,50])rotate([0,0,-90])rotate([90,0,0])text("16     |    Europa Grenzenlos    |    16", size=200);

color("gray"){
    wand();
    translate([4000,0,0])mirror([1,0,0])wand();
}

translate([500,2000,0])cube_([3000, 2000, 1000], anchor=FRONT+BOTTOM+LEFT);

color("white"){
    translate([1000,2000,1000]){
        polyhedron([[100,500,0],[1900,500,0],[1900,2000,0],[100,2000,0],[0,0,1500],[2000,0,1500],[2000,2000,1500],[0,2000,1500]],[[0,1,2,3],[1,0,4,5],[2,1,5,6],[3,2,6,7],[0,3,7,4],[7,6,5,4]]);
        translate([-250,-250,1500])cube([2500,2250,10]);
        translate([1000-375,1000,1510])polyhedron([[0,0,0],[750,0,0],[750,750,0],[0,750,0],[125,500,1000],[625,500,1000],[625,1000,1000],[125,1000,1000]],[[0,1,2,3],[1,0,4,5],[2,1,5,6],[3,2,6,7],[0,3,7,4],[7,6,5,4]]);
    }
}

translate([40,3000,600])rotate([0,-atan(0.3),0])rotate([0,0,-90])rotate([90,0,0])text("Coast Guard", size = 150);