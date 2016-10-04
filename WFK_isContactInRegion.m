function logicalResult = WFK_isContactInRegion(x,y,z,faces,vertices,flipNorms)
% 
% Returns true (1) if the contact located at coordinate x,y,z is
% contained within the atlas region given by the faces and vertices.
% Returns false (0) otherwise.
% Uses the inpolyhedron function.
%
QPtsX = [x];
QPtsY = [y];
QPtsZ = [z];
logicalResult = inpolyhedron(faces,vertices,QPtsX,QPtsY,QPtsZ,'FLIPNORMALS',flipNorms);
end

