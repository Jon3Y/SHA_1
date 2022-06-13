%SHA-1 function;
%format long G
%num--hex_str, such as 0xffffffff_...(14)..._ffffffff;
function s = sha_1(hex512)

%sha-1, h0~h4;
h0 = uint32(0x67452301);
h1 = uint32(0xefcdab89);
h2 = uint32(0x98badcfe);
h3 = uint32(0x10325476);
h4 = uint32(0xc3d2e1f0);

%sha-1, k;
k0 = uint32(0x5a827999);
k1 = uint32(0x6ed9eba1);
k2 = uint32(0x8f1bbcdc);
k3 = uint32(0xca62c1d6);

%512bit -> 16*32bit;
din = uint32(zeros(1,16));
for i = 1:1:16
    str = hex512(((i-1)*8+1):(i*8));
    din(i) = uint32(hex2dec(str));
end

a = h0;
b = h1;
c = h2;
d = h3;
e = h4;

w_r = uint32(zeros(1,80));

for t = 1:1:80

    x = bitget(uint32(a),28:32);
    temp_0 = bitshift(uint32(a),5);
    temp_0 = bitset(uint32(temp_0),1,x(1));
    temp_0 = bitset(uint32(temp_0),2,x(2));
    temp_0 = bitset(uint32(temp_0),3,x(3));
    temp_0 = bitset(uint32(temp_0),4,x(4));
    temp_0 = bitset(uint32(temp_0),5,x(5));

    f = f_t(t,b,c,d);

    [w,w_r] = w_t(t,din,w_r);

    if t<=20
        k = k0;
    elseif t>=21 && t<=40
        k = k1;
    elseif t>=41 && t<=60
        k = k2;
    elseif t>=61 && t<=80
        k = k3;
    end
    
    temp = double(temp_0) + double(f) + double(e) + double(w) + double(k);
    temp_1 = dec2bin(temp);
    temp_2 = temp_1(end-31:end);
    temp = uint32(bin2dec(temp_2));

    e = d;
    d = c;
    x_0 = bitget(uint32(b),1:2);
    b_0 = bitshift(uint32(b),-2);
    b_0 = bitset(uint32(b_0),31,x_0(1));
    b_0 = bitset(uint32(b_0),32,x_0(2));
    c = b_0;
    b = a;
    a = temp;
end

s0 = dec2bin((double(h0) + double(a)),32);
s0 = uint32(bin2dec(s0(end-31:end)));
s1 = dec2bin((double(h1) + double(b)),32);
s1 = uint32(bin2dec(s1(end-31:end)));
s2 = dec2bin((double(h2) + double(c)),32);
s2 = uint32(bin2dec(s2(end-31:end)));
s3 = dec2bin((double(h3) + double(d)),32);
s3 = uint32(bin2dec(s3(end-31:end)));
s4 = dec2bin((double(h4) + double(e)),32);
s4 = uint32(bin2dec(s4(end-31:end)));

s = [dec2hex(s0,8),dec2hex(s1,8),dec2hex(s2,8),dec2hex(s3,8),dec2hex(s4,8)];

end