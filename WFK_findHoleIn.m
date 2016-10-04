function [ holeImage ] = WFK_findHoleIn(binaryImage)
% Traverse the binaryImage from all directions, counting the
% number of transitions from off to on; identify as a hole any
% pixel for which there are two transitions involved in getting
% to that pixel,from all directions.
nRows = size(binaryImage,1);
nCols = size(binaryImage,2);
% from the West
West = zeros(nRows,nCols);
for r = 1:nRows
    nTrans = 0;
    West(r,1) = nTrans;
    val = binaryImage(r,1);
    for c = 2:nCols
        nextVal = binaryImage(r,c);
        if ~(val == nextVal)
            nTrans = nTrans + 1;
        end;
        West(r,c) = nTrans;
        val = nextVal;
    end;
end;
% from the East
East = zeros(nRows,nCols);
for r = 1:nRows
    nTrans = 0;
    East(r,nCols) = nTrans;
    val = binaryImage(r,nCols);
    for c = nCols:-1:1
        nextVal = binaryImage(r,c);
        if ~(val == nextVal)
            nTrans = nTrans + 1;
        end;
        East(r,c) = nTrans;
        val = nextVal;
    end;
end;
% from the North
North = zeros(nRows,nCols);
for c = 1:nCols
    nTrans = 0;
    North(1,c) = nTrans;
    val = binaryImage(1,c);
    for r = 2:nRows
        nextVal = binaryImage(r,c);
        if ~(val == nextVal)
            nTrans = nTrans + 1;
        end;
        North(r,c) = nTrans;
        val = nextVal;
    end;
end;
% from the South
South = zeros(nRows,nCols);
for c = 1:nCols
    nTrans = 0;
    South(nRows,c) = nTrans;
    val = binaryImage(1,c);
    for r = nRows:-1:1
        nextVal = binaryImage(r,c);
        if ~(val == nextVal)
            nTrans = nTrans + 1;
        end;
        South(r,c) = nTrans;
        val = nextVal;
    end;
end;
% Find even counts greater than zero, in each direction.
northEven = (mod(North,2) == 0)  & (North > 0);
southEven = (mod(South,2) == 0)  & (South > 0);
eastEven =  (mod( East,2) == 0)  & ( East > 0);
westEven =  (mod( West,2) == 0)  & ( West > 0);
sumEven = northEven + southEven + eastEven + westEven;
holeImage = sumEven == 4;
end

