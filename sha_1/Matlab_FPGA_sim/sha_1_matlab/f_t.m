%SHA-1 f(t) cal;
%t--cycle rounds;
%b--uint32;
%c--uint32;
%d--uint32;
function f = f_t(t,b,c,d)

if t<=20
    f0 = bitand(b,c);
    f1 = bitand(bitcmp(b),d);
    f = bitor(f0,f1);
elseif t>=21 && t<=40
    f0 = bitxor(b,c);
    f = bitxor(f0,d);
elseif t>=41 && t<=60
    f0 = bitand(b,c);
    f1 = bitand(b,d);
    f2 = bitand(c,d);
    f3 = bitor(f0,f1);
    f = bitor(f3,f2);
elseif t>=61 && t<=80
    f0 = bitxor(b,c);
    f = bitxor(f0,d);
end

end