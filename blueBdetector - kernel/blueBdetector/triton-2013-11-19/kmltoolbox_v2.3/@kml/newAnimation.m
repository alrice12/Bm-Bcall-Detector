function f = newAnimation(this,animName)
%KML.NEWANIMATION(folderName) Creates an animation storyboard inside an kml (or another folder).
%  Example of use:
%
%   Copyright 2012 Rafael Fernandes de Oliveira (rafael@rafael.aero)
%   $Revision: 1.1 $  $Date: 2013/06/03 20:05:48 $

    if nargin < 2
        animName = 'Unnamed Animation';
    end
    f = kmlAnimation(this,animName);
end