include <components.scad>

h = 1500;

//Mittleres, gerades Modul
module schiffwand1(){
    polyhedron([[300,0,0],[500,0,0],[500,1000,0],[300,1000,0],[0,0,h/2],[0,1000,h/2],[0,0,h],[500,0,h],[500,1000,h],[0,1000,h]],[[0,1,2,3],[1,0,4,6,7],[2,1,7,8],[3,2,8,9,5],[0,3,5,4],[4,5,9,6],[9,8,7,6]]);
}

//leicht geneigtes Modul
module schiffwand2(){
    polyhedron([[500,0,0],[500,1000,0],[300,1000,0],[200,0,h/2],[0,1000,h/2],[200,0,h],[500,0,h],[500,1000,h],[0,1000,h]],[[0,1,2],[0,3,5,6],[1,0,6,7],[2,1,7,8,4],[0,2,4,3],[3,4,8,5],[8,7,6,5]]);
}

//Modul für den Bug
module schiffwand3(){
    polyhedron([[500,1000,0],[500,0,h/2],[200,1000,h/2],[500,0,h],[500,1000,h],[200,1000,h]],[[0,2,1],[0,1,3,4],[0,4,5,2],[1,2,5,3],[5,4,3]]);
}

//wie Modul1, aber mit Schräge auf der Oberseite
module schiffwand4(){
    polyhedron([[300,0,0],[500,0,0],[500,1000,0],[300,1000,0],[0,0,h/2],[0,1000,h/2],[0,0,h],[500,0,h],[500,1000,0.75*h],[0,1000,0.75*h]],[[0,1,2,3],[1,0,4,6,7],[2,1,7,8],[3,2,8,9,5],[0,3,5,4],[4,5,9,6],[9,8,7,6]]);
}

//wie Modul2, aber mit geringerer Höhe
module schiffwand5(){
    polyhedron([[500,0,0],[500,1000,0],[300,1000,0],[200,0,h/2],[0,1000,h/2],[200,0,0.75*h],[500,0,0.75*h],[500,1000,0.75*h],[0,1000,0.75*h]],[[0,1,2],[0,3,5,6],[1,0,6,7],[2,1,7,8,4],[0,2,4,3],[3,4,8,5],[8,7,6,5]]);
}

module wand(){
    translate([0,2000,0]) schiffwand1();
    translate([0,1000,0]) schiffwand2();
    schiffwand3();
    translate([0,3000,0]) schiffwand4();
    translate([0,5000,0])mirror([0,1,0]) schiffwand5();
}

module wand2(){
    translate([250,500,0])prism_([500,1000,h],spin=180,anchor=BOTTOM, covers=PLATE_RIGHT);
    translate([250,2000,0])cube_([500,2000,h],anchor=BOTTOM,covers=PLATE_LEFT);
    translate([250,3500,0])cube_([500,1000,0.75*h-beam_width],anchor=BOTTOM,covers=PLATE_LEFT);
    translate([250,4500,0])mirror([1,0,0])prism_([500,1000,0.75*h],anchor=BOTTOM,covers=PLATE_RIGHT);
    translate([250,3500,0.875*h-beam_width/2])prism_([1000,0.25*h+beam_width,500],orient=RIGHT,spin=90);
}

//wand2();