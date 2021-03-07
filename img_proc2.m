%% image processing code
function [home_detected,home_center] = img_proc2(img)
    home_detected = 0; 
    home_center   = 0;
    
    %img= imread('home.jpg'); % test img
    %------------------------------------------------%
    % conversion from RGB to HSV
    im_HSV = rgb2hsv(img);
    % divide the image in 3 channels for H, S and V
    im_H = im_HSV(:,:,1); 
    im_S = im_HSV(:,:,2);
    im_V = im_HSV(:,:,3);
    %------------------------------------------------%
    % Segmentation for yellow color (using danger1.jpg)
    h_inf = 0.523;
    h_sup = 0.695;
    im_H_BIN = roicolor(im_H,h_inf,h_sup);
    s_inf = 0.349;
    s_sup = 1;
    im_S_BIN = roicolor(im_S,s_inf,s_sup);
    v_inf = 0.410;
    v_sup = 1;
    im_V_BIN = roicolor(im_V,v_inf,v_sup);
    % AND operation to multiply all channels
    im_BIN = im_H_BIN.*im_S_BIN.*im_V_BIN;
    %------------------------------------------------%
    im_BW = ~(im_BIN);
    
    % delete the biggest object detected in the image (winwdow)
    CC = bwconncomp(im_BW);
    numPixels = cellfun(@numel,CC.PixelIdxList);
    [~,idx] = max(numPixels);
    im_BW(CC.PixelIdxList{idx}) = 0;
    
    % delete objects with less than 50 px of area
    Objects_aux = bwareaopen(im_BW, 50); 
    Objects = bwconncomp(Objects_aux, 8);

    %% classify the objects detected (circle, triangle or rectangle)
    % if only 1 object rectangle is detected we detect the home
    Objects.NumObjects
    if Objects.NumObjects > 0
        [~,L,N] = bwboundaries(Objects_aux);
        % get stats
        stats=  regionprops(L, 'Centroid', 'Area', 'Perimeter','BoundingBox');
        Perimeter = cat(1,stats.Perimeter);
        Area = cat(1,stats.Area);
        CircleMetric = (Perimeter.^2)./(4*pi*Area);  % circularity metric
        
        if CircleMetric(1) < 1.53 && CircleMetric(1) > 1.19 % rectangle
            fprintf('Home detected \n')
            home_detected = 1;
            home_center = stats(1).Centroid;
        end
        
        % show image and labels with results
        imshow(img); 
        hold on;
        for k=1:N
           Im_Obj_Area_AUX = false(size(Objects_aux));
           Im_Obj_Area_AUX(Objects.PixelIdxList{k})=true;
           boundaries = bwboundaries(Im_Obj_Area_AUX);
           b = boundaries{1};
           plot(b(:,2),b(:,1),'r--','LineWidth',2);
        end
       hold off;
    end 
end