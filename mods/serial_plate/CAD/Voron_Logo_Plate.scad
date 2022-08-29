font1="Play";
serial="V2.3934";
logo=true;
serial_length=len(serial);

baseplate= "Serial_Plate_Voron_mod.stl";

difference(font1, serial, logo) {
    rotate([270,180,0]) translate([-44.5,0,-20]) import(baseplate, convexity=20, center=true); 
    rotate([180,0,0]) translate([12,7,-1]) linear_extrude(20, convexity=20) text(text=serial, font=font1, size=8, halign="center");
}
