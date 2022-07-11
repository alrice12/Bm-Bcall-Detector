function disp_msg(msg)
%
% display message in window
%
% 060219 smw
%

global HANDLES

x = get(HANDLES.msg,'String');

lx = length(x);



x(lx+1) = {msg};



set(HANDLES.msg,'String',x,'Value',lx+1)

