function [data, data_512bit] = gen_bits()

data = zeros(1,64);
for i=1:1:55
    data(i) = randi([0x00,0xff],1);
end
data(56) = 0x80;
for i=1:1:6
        data(i+56) = 0x00;
end
data(63) = 0x01;
data(64) = 0xB8;

data_hex = dec2hex(data);
data_str = mat2str(data_hex);
data_512bit = erase(data_str, [";","[","]","'"]);

end