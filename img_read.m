%% function executed to read image from ipcam
function [img] = img_read()
    url = 'http://192.168.0.101:8080/shot.jpg';
    img = imread(url);
    fh = image(img);
    set(fh,'CData',img);
end