%SHA-1 w(t) cal;
%t--cycle rounds;
%m--uint32 1*16;
%w_r--w buffer;

function [w,w_r] = w_t(t,m,w_r)

if t<=16
    w = m(t);
elseif t>=17 && t<=80
    w0 = bitxor(w_r(t-3),w_r(t-8));
    w1 = bitxor(w0,w_r(t-14));
    w2 = bitxor(w1,w_r(t-16));
    x = bitget(uint32(w2),32);
    w3 = bitshift(uint32(w2),1);
    w = bitset(uint32(w3),1,x);    
end

w_r(t) = w;

end



