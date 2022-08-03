/*
 * Voron 2.4 fan cover 
 * by fbeauKmi : https//github.com/fbeauKmi/Voron2.4/mod/fan_grid
 * widely inspired by  Customizable Fan Cover by Dennis Hofmann
 * created 2022-07-24
 * version v1.0
 *
 * Changelog
 * --------------
 * v1.0:
 *      - first release
 * V1.1:
 *      - Add R1 version
 * V1.2:
 *      - New pattern
 *      - fixes file name suggestion
 * V1.3:
 *      - Add R1_blank model
 * --------------
 *
 * This work is licensed under the Creative Commons - Attribution - Non-Commercial - ShareAlike license.
 * https://creativecommons.org/licenses/by-nc-sa/3.0/
 */


// Parameter Section //
//-------------------//

/* [Fan grid settings] */

// Part A or B or R1 version(determine rear pocket side)
Part = "A"; //[A,B,R1,R1_blank]
Pattern_model = "Honeycomb"; //[V2.4,V2.4_rings,V2.4_interpolate,Honeycomb,HoneyLogo,Triangle,Diamond]
// Logo model (does not affect V2.4s & HoneyLogo model) 
Logo = "Voron"; //[Voron,Voron2,none]
// Rotate grid pattern
// only for Honeycomb, Triangle & Diamond
Pattern_angle = 0; //[0,30,60,90,120,150]
// holes max diameter in mm
hole_dia = 9; //[5:0.1:12] 
// grid wall min width in mm
line_width= 0.8; //[0.4:0.01:2]

// change hole size  f(center distance) /
// only for Honeycomb, Triangle & Diamond
variable_line_width = 0; //[-1:0.1:1]

//-------------------//
$variable_hole=variable_line_width;


fan_grid(
    grid_pattern = Pattern_model,
    model=Part,
    hole_dia=hole_dia,
    line_width=line_width,
    logo = Logo,
    pattern_angle=Pattern_angle
    );


module fan_grid(
                grid_pattern = "Honeycomb",
                model = "A",
                hole_dia = 9,
                line_width = 0.8,
                logo= "none",
                pattern_angle=120){
                    
    cover_size = 60;
    screw_hole_distance = 50.38;
    screw_hole_dia = 3.5;
    cover_h = 3.2;                
    corner_size = cover_size - screw_hole_distance;
    corner_r =  corner_size / 2 ;
    screw_pos = (cover_size - corner_size) / 2;
    
    size_logo=18.1;
    $v24=startWith(grid_pattern,"V2.4");
    $special=grid_pattern=="HoneyLogo";
    
        
    intersection(){
        difference(){
            fan_frame(cover_size=cover_size,corner_r=corner_r,cover_h=cover_h);
            if(!startWith(model,"R1_blank"))screw_holes(screw_pos=screw_pos,screw_hole_dia=screw_hole_dia);
            if(!startWith(model,"R1")) rear_pockets(screw_pos=screw_pos,r=corner_r,model=model);
        }
        
            
        

        if($v24){
            chamfer(h=0.4,height=cover_h, pos="bottom")
            //linear_extrude(height=cover_h)
            difference(){
                    square(cover_size+10,center=true);
                    pattern_v24(size=cover_size);
                    pattern_logovoron2(size=15);
            }

            if (grid_pattern=="V2.4_rings"){
                linear_extrude(height=cover_h-1.6,convexity=50)
                    pattern_circle(size1=25, size2=cover_size-line_width,hole_dia=hole_dia,line_width=line_width, nb_lines=3);
            }
            if (grid_pattern=="V2.4_interpolate"){
                linear_extrude(height=cover_h-1.6,convexity=50)
                    pattern_interpolate_lines(size1=12.5+ line_width, size2=(cover_size-line_width)/2,line_width=line_width,nb_lines=3);
            }
            
        } else if($special){
            difference(){
                union(){
                    chamfer(h=0.8,height=cover_h)
                    difference(){
                            square(cover_size+10,center=true);
                             
                        grid_area(size=cover_size);
                    }
                    linear_extrude(height=cover_h/2,convexity=50) square(cover_size+10,center=true);
                }
                translate([0,0,-1])
                    linear_extrude(height=cover_h+2, convexity=20)
                        pattern_special(size=cover_size,line_width=line_width);
            }

        } else {
        
            chamfer(h=0.4,height=cover_h)
            difference(){
                    square(cover_size+5,center=true);
                    grid_area(size=cover_size);
            }

            intersection(){
                linear_extrude(height=cover_h) grid_area(size=cover_size+1);
                linear_extrude(height=cover_h-1.6,convexity=20)
                difference(){
                    square([cover_size,cover_size],center=true);
                    rotate(pattern_angle) 
                    if (grid_pattern == "Triangle"){
                        pattern_triangle(size=cover_size,hole_dia=hole_dia,line_width=line_width);
                    } else if (grid_pattern=="Honeycomb"){
                        pattern_honeycomb(size=cover_size,hole_dia=hole_dia,line_width=line_width);
                    } else if (grid_pattern=="Diamond"){
                        pattern_diamond(size=cover_size,hole_dia=hole_dia,line_width=line_width);
                    } else if (grid_pattern=="V2.4"){
                        pattern_v24(size=cover_size);
                    }                      
                    if(logo == "Voron") rotate(30) 
                        circle(r = size_logo/2,$fn=6);
                }
            }
            if(logo == "Voron") chamfer(h=.4,height=cover_h/2) pattern_logovoron(size=size_logo);
            if(logo == "Voron2") chamfer(h=.4,height=cover_h/2) pattern_logovoron2(size=size_logo*1.75);
        }   
    }
    if(startWith(model,"R1_blank")) r1_height(cover_size=cover_size,corner_r=corner_r,cover_h=cover_h);
    
    echo ("Rename our STL :");
    $exported_filename= str("[a]_fan_grid_" , model , "_", grid_pattern,
    (grid_pattern=="V2.4" || grid_pattern=="HoneyLogo" ?"":
        str(  
        startWith(grid_pattern,"V2.4")?str("_L",line_width<1?join(slice(str(line_width),1)):line_width): str(
    (logo!= "none"? str("_" , logo) :""),
    (pattern_angle > 0? str("_A",pattern_angle):"") ,
    "_H" , (len(str(hole_dia))<3?str(hole_dia,".0"):hole_dia), 
    "_L" , (line_width<1?join(slice(str(line_width),1)):line_width) ,
    $variable_hole != 0 ? str("_V" , $variable_hole):""))), ".stl");
    echo($exported_filename);
}

module fan_frame(cover_size,corner_r,cover_h){
    chamfer(h=1,height=cover_h,pos="bottom") {
        offset(r=corner_r, $fn = 32) {
            offset(r=-corner_r) {
                square([cover_size, cover_size], center = true);
            }
        }     
    }
   if($v24){
        linear_extrude(height=cover_h) circle(d=cover_size, $fn=ceil(cover_size*2));
    }
    
 }
 
module r1_height(cover_size,corner_r,cover_h,height=20){
    translate([0,0,cover_h-0.05])
    linear_extrude(height=height-cover_h+0.05){
        difference(){
            offset(r=corner_r, $fn = 32) {
                offset(r=-corner_r) {
                    square([cover_size, cover_size], center = true);
                }
            }
            offset(r=corner_r-1.6, $fn = 32) {
                offset(r=-corner_r+1.6) {
                    square(cover_size-3.2, center = true);
                }
            }
        }
    }
}

//## 2D modules
module grid_area(size){
    if($v24){
        circle(d=size-1.001, $fn=ceil(size*2));
    } else {
        offset(r=2, $fn=10) offset(delta=-2)
        intersection(){
            square(size=size-3.2, center=true);
            rotate([0,0,30]) circle(d=size+7, $fn=6);
        }
    }
}

module pattern_v24(size, angle=0){    
    offset(r=2,$fn=10) offset(r=-2,$fn=15)
    difference(){
        circle(d=size-2.4, $fn=ceil(size));
        rotate(30) circle(d=30, $fn=6);
        for(i = [0:2]){
            rotate( angle + i*60) square([3,size+5],center=true);
        }
    }   
}

module pattern_circle(size1,size2, hole_dia, line_width, nb_lines=2){
    e=(size2-size1)/(nb_lines+1)/2;
    echo("Circles");
    for( i = [1:nb_lines]){
            difference(){
                d1= size1/2 + e * i -line_width/2;
                d2=d1 + line_width;
                circle(r=d2,$fn=ceil(d2 * 4));
                circle(r=d1,$fn=ceil(d2 * 4));
            }
    }  
}

module pattern_interpolate_lines(size1, size2, line_width, nb_lines=1){
    e=1/(nb_lines+1);
    hw = line_width/2;
    for(n=[1:nb_lines]){
        g=e*n;
        
        f=1-g;
            
        d1 = [for(i =[0:59]) 
                let(a=i*6, l=(0.866/cos(a%60-30)*size1*g+size2*f))
                [cos(a)*(l-hw),sin(a)*(l-hw)]];
        d2 = [for(i =[0:59]) 
                let(a=i*6, l=(0.866/cos(a%60-30)*size1*g+size2*f))
                [cos(a)*(l+hw),sin(a)*(l+hw)]];
            
     
        difference(){
            polygon(points=d2);
            polygon(points=d1);
        }
    }
}


module pattern_honeycomb(size, hole_dia, line_width){
    x_dist = hole_dia * 0.866 + line_width;
    y_dist = x_dist * 0.866;
    min_col = ceil(size / (2 * x_dist));
    min_row = ceil(size / (2 * y_dist)); 
    
    for( x = [-min_col:min_col]){
        for( y = [-min_row:min_row]){
            odd = (y%2) / 2;
               dist= sqrt(((x+odd)*x_dist)^2+ (y*y_dist)^2)/(size/2);
               modif= variable_h(dist);
            
            translate([(x+odd) * x_dist, y * y_dist ,0]){
                    rotate(30) circle(d=hole_dia*modif,$fn=6);
            }
        }
    }        
}

module pattern_triangle(size, hole_dia, line_width){
   x_dist = hole_dia/2 + line_width;
   y_dist = x_dist * 0.866;
    min_onrow = ceil(size / (2 * x_dist));
    min_oncol = ceil( min_onrow / sin(30)); 
   
    for( x = [-min_onrow:min_onrow]){
        for( y = [-min_oncol:min_oncol]){
            odd_y = abs((y%2) / 2);
            odd_x = abs((x%2) / 2);
            cur_x = (ceil((3*x+1)/2) + odd_y*3) * x_dist;
            cur_y = y * y_dist;
               dist= sqrt(cur_x^2+ cur_y^2)/(size/2);
               
               modif= variable_h(dist);
               translate([cur_x, cur_y ,0]){
                        rotate(60+120*odd_x) circle(d=hole_dia*modif,$fn=3);
               }
        }
    }    
}

module pattern_diamond(size, hole_dia, line_width){
   x_dist = (hole_dia + line_width) * 1.73;
   y_dist = (hole_dia  + line_width )/2 ;
    min_col = ceil(size / (2 * x_dist));
    min_row = ceil(size / (2 * y_dist)); 
    
    for( x = [-min_col:min_col]){
        for( y = [-min_row:min_row]){
            odd = abs((y%2) / 2);
            cur_x = (x+ odd) * x_dist;
            cur_y = y * y_dist;
            dist= sqrt((abs(cur_x) - x_dist/4)^2+ cur_y^2)/(size/2);
            modif= variable_h(dist);
            d=hole_dia*(modif);
            translate([cur_x, cur_y ,0]){
                polygon( points=[[d*.866,0],[0,-.5*d],[-d*.866,0],[0,.5*d]]);
            }
        }
    }    
}

module pattern_special(size, line_width){
 datas = [[0,2,5,10,5,2,0],
        [2,5,10,10,10,10,5,2],
        [10,10,5,10,5,10,10],
        [5,10,5,10,5,10,10,5],
        [10,5,10,5,10,5,10],
        [5,10,10,5,10,5,10,5],
        [10,10,5,10,5,10,10],
        [2,5,10,10,10,10,5,2],
        [0,2,5,10,5,2,0]];
    y_dist = (size-4)/9;
    x_dist = y_dist/0.866;
    
    for(y = [0:8]){
      odd = 1- abs(y%2);
      for(x = [0:7-odd]){
          odd = 1-(y%2);
          d= datas[y][x]==0?0:(x_dist/.866-line_width)*(datas[y][x]+10)/20;
          translate([(x-3.5+odd/2)*x_dist,(y-4)*y_dist,0]) 
          rotate(30) circle(d=d,$fn=6);
      }
  }   
}

module pattern_logovoron(size){
    scale(size/52)
    difference(){
    rotate(30) circle(d = 60, $fn=6);
    polygon(points = [[17.5,0],[10.5,14],[3.5,14],[10.5,0]]);
    polygon(points = [[-17.5,0],[-10.5,-14],[-3.5,-14],[-10.5,0]]);    
    polygon(points = [[10.5,-14],[-3.5,14],[-10.5,14],[3.5,-14]]);
    } 
}
module pattern_logovoron2(size){
    scale(size/35)
    {
    polygon(points = [[17.5,0],[10.5,14],[3.5,14],[10.5,0]]);
    polygon(points = [[-17.5,0],[-10.5,-14],[-3.5,-14],[-10.5,0]]);    
    polygon(points = [[10.5,-14],[-3.5,14],[-10.5,14],[3.5,-14]]);
    }
}

module screw_holes(screw_pos,screw_hole_dia){
    for(y = [-1:2:1]) {
        for(x = [-1:2:1]) {
            translate([x*screw_pos,y*screw_pos,-1]){    
                union(){
                    linear_extrude(height=5){
                            circle(d=screw_hole_dia, $fn=32);
                    }
                    linear_extrude(height=2){
                            circle(d=screw_hole_dia*1.75, $fn=64);
                    }
                    linear_extrude(height=2.2){
                        intersection(){
                            square([screw_hole_dia,screw_hole_dia*2],center=true);
                            circle(d=screw_hole_dia*1.75, $fn=64);       
                        }
                    }
                    linear_extrude(height=2.4){
                            square(screw_hole_dia,center=true);
                    }               
                }
            }
        }
    }  
}

module rear_pockets(screw_pos,r,model){
    escp = model=="A"?[-1,1]:[1,1]; 
    translate([0,0,2.2]) linear_extrude(height=5, convexity=20){
        round_outside(r=1.6)
        union(){    
        for(y = [-1:2:1]) {
            for(x = [-1:2:1]) {
                if(x!=escp[0] || y!=escp[1]){
                     translate([x*screw_pos,y*screw_pos,0]){
                            circle(r=r, $fn=32);
                            translate([x*r,0,0]){
                                square(r*2,center=true);
                            }
                            translate([0,y*r,0]){
                                square(r*2,center=true);
                            }
                            translate([0,y*r*2,0]){
                                square([r*4,r*2],center=true);
                            }
                            translate([x*r*2,0,0]){
                                square([r*2,r*4],center=true);
                            }
                        }
                    }
                }
            }
        }
    }    
}

module chamfer(h, height, pos="both"){
    assert(height > 2*h, "Height should be greater than chamfer");
    
    both = [[0,0],[h,h],[0,2*h]];
    top = [[0,0],[h,0],[0,h]];
    bottom = [[0,0],[h,h],[0,h]];
    
    border = pos=="both"?both:pos=="top"?top:bottom;
    mult = pos=="both"?2:1;
    
    minkowski(){
        rotate_extrude($fn=ceil(h*10)) polygon(points=border, paths=[[0,1,2]]);
        linear_extrude(height=height-h*mult,convexity=25)
        offset(delta=-h){
            children();
        }
    }   
}

module fillet(h, height, pos="both"){
    assert(height > 2*h, "Height should be greater than fillet");
    
    //border = pos=="both"?both:pos=="top"?top:bottom;
    mult = pos=="both"?2:1;
    
    minkowski(){
        translate([0,0,h]) 
        if(pos==both)
         sphere(r=h,$fn=ceil(h*20));
        if(pos=="top" || pos=="bottom")
          union(){
              translate([0,0,(pos=="top"? -h:h)/2]) cylinder(h=h,r=h, center=true);
              sphere(r=h,$fn=ceil(h*20));
          }    
        linear_extrude(height=height-h*mult,convexity=25)
        offset(delta=-h, $fn=20){
            children();
        }
    }   
}

module round_outside(r){
    offset(r=-r,$fn=32) offset(r=r,$fn=32) children();
}

function variable_h (dist) = 
    $variable_hole > 0?
        (dist-1)*$variable_hole/2 + 1
    : 1+(dist)*$variable_hole/4; 

function slice(string, start=0, end=-1) =
    join(_slice(string, start=0, end=-1));

function _slice(array, start=0, end=-1) = 
	array == undef?
		undef
	: start == undef?
		undef
	: start >= len(array)?
		[]
	: start < 0?
		_slice(array, len(array)+start, end)
	: end == undef?
		undef
	: end < 0?
		_slice(array, start, len(array)+end)
	: end >= len(array)?
        undef
    : start > end && start >= 0 && end >= 0?
        _slice(array, end, start)
	: 
        [for (i=[start:end]) array[i]];
            
function join(strings, delimeter="") = 
	strings == undef?
		undef
	: strings == []?
		""
	: _join(strings, len(strings)-1, delimeter);

function _join(strings, index, delimeter) = 
	index==0 ? 
		strings[index] 
	: str(_join(strings, index-1, delimeter), delimeter, strings[index]) ;

function startWith(string, pattern) =
        len(string)<len(pattern)?
            false
        : [for (i=[0:len(pattern)-1]) string[i]] == [for (i=[0:len(pattern)-1]) pattern[i]]?
            true
        : false;