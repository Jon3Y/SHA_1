clc
clear

%connect to uart port;
serialportlist;
port = serialport("COM11",9600);

%gen 512bit hex;
num = zeros(1,64);
for i=1:1:55
    num(i) = randi([0x00,0xff],1);
end
num(56) = 0x01;
for i=1:1:6
    num(i+56) = 0x00;
end
num(63) = 0x01;
num(64) = 0xB8;

%trans hex to uart;
write(port,num,"uint8");

%call matlab function to compare;
hex = dec2hex(num);
hexstr = mat2str(hex);
hex512 = erase(hexstr, [";","[","]","'"]);
code = sha_1(hex512);

%remove independent var;
clear hex hex512 hexstr i ans

%output;
msgbox(code,"SHA-1 code");