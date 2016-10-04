function sumBrightness  = WFK_donutHoleBrightnessForContact(c,slice,candidateCoords,offset)
% Compute a new set of coordinates by applying the offset to the
% candidate coordinates, then sum the pixel brightness values in the region
% surrounding coordinate c's slice of the image based on the trajectory.
%
coords = candidateCoords + offset;
sumBrightness = 0;
% for c = 1:4
    Cx = coords(c,1);
    Cy = coords(c,2);
    Cz = coords(c,3);
%   sum the pixels in a 5x5 box
    maxX = size(slice,1);
    maxY = size(slice,2);
    for xx = -2:2
        x = Cx + xx;
        if x < 1
            x = 1;
        end;
        if x > maxX
            x = maxX;
        end;
        for yy = -2:2
            y = Cy + yy;
            if y < 1
                y = 1;
            end;
            if y > maxY
                y = maxY;
            end;
            brightness = slice(x,y);
            sumBrightness = sumBrightness + brightness;
        end;
    end;
% end


