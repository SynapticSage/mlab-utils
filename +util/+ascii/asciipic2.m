function [ imgascii ] = asciipic2( img, gcf, filename )

%asciis=[' .,:;rsiS52X39hGAHBM#&@'];
%asciis=[' .,:;risS52X3AGhHB9M#&@'];
%asciis=[' .,:;risA523XGShHM#B9&@'];
asciis= [' .,:;irXAs253hMHGS#9B&@'];
%asciis=['`''..-,:"_!~/\;*|^<+7r?v=iJLlYc)T{(}tsIVCxF325]1[uU4nzAXjfoZSyPweaKEHkGOh0M$N9#dq6RmDW%bpQ8Bg@&'];


if isa(img, 'char') || isa(img,'string')
    temp=imread(img,'jpg');
else
    temp = img;
    if ismatrix(temp)
        temp = repmat(temp, 1,1,3);
    end
end
imwrite(temp,'/tmp/img.bmp','bmp');
img=imread('/tmp/img.bmp','bmp');
img = imadjust(img, [0 0.8], [0 0.7]);
if ~ismatrix(img)
    img=rgb2gray(img);
else
    img = 255 * (img - min(img, [], 'all'))./(max(img, [],'all')-min(img, [],'all'));
end

[rows, cols]=size(img);

%img=abs(hex2dec(dec2hex(img))-255);
img = 255 - double(img);
%img=reshape(img, rows, cols);

%extrarows=mod(rows,13);
%extracols=mod(cols,8);

extrarows=mod(rows,7);
extracols=mod(cols,4);

img=img(1:(end-extrarows),1:(end-extracols));

[rows, cols] = size(img);

%denseboxes=zeros(rows/13,cols/8);
denseboxes=zeros(rows/7,cols/4);


for ii=1:7%13
    for oo=1:4%13
        pixels=img(ii:7:end,oo:4:end);% pixels=img(ii:13:end,oo:8:end);
        denseboxes = denseboxes + pixels;
    end
end

%gcf=2.1;
denseboxes = denseboxes - min(min(denseboxes));
denseboxes = denseboxes./max(max(denseboxes));
denseboxes = denseboxes.^gcf;

map=linspace(min(min(denseboxes)),max(max(denseboxes)),23);
%map=max(max(denseboxes))+min(min(denseboxes))-logspace(log10(min(min(denseboxes))),log10(max(max(denseboxes))),23);

%imgascii=zeros(rows/13,cols/8);
imgascii=zeros(rows/7,cols/4);

for ii=1:(rows/7)%13
    for jj=1:(cols/4)%8
        which_char=1;
        for kk=1:numel(map)
            if denseboxes(ii,jj)>=map(kk)
                which_char=which_char+1;
            end
        end
        if(which_char>23),which_char=23; end
        imgascii(ii,jj)=asciis(which_char);
    end
end
imgascii=char(uint8(imgascii));

if nargin > 2
    fid = fopen(filename, 'w');
    for ii=1:size(imgascii,1)
        fprintf(fid, '%s\r\n', imgascii(ii,:));
    end
    fclose(fid);
end


