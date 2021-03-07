%% image processing code
function [bomb_detected,bomb_center,accuracy] = img_proc(img)
    bomb_detected = 0; 
    bomb_center   = 0;
    accuracy      = 0;
    aux1 = 0;
    aux2 = 0;
    idx_ret = 0;
    idx_tri = 0;
    
    %img = imread('danger2.jpg'); % image test
    %------------------------------------------------%
    % conversion from RGB to HSV
    im_HSV = rgb2hsv(img);
    % divide the image in 3 channels for H, S and V
    im_H = im_HSV(:,:,1); 
    im_S = im_HSV(:,:,2);
    im_V = im_HSV(:,:,3);
    %------------------------------------------------%
    % Segmentation for yellow color (using danger1.jpg)
    h_inf = 0.100;
    h_sup = 0.198;
    im_H_BIN = roicolor(im_H,h_inf,h_sup);
    s_inf = 0.218;
    s_sup = 1;
    im_S_BIN = roicolor(im_S,s_inf,s_sup);
    v_inf = 0.682;
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

    Objects_aux = bwareaopen(im_BW, 50); % delete objects with less than 50 px of area
    Objects = bwconncomp(Objects_aux, 8);

    %% classify the objects detected (circle, triangle or rectangle)
    % if only 1 object is detected we are going to assume that is the big
    % triangle so variable accuracy will be 50 and we will want to confirm it
    % latter...
    
    if Objects.NumObjects > 0
        [~,L,N] = bwboundaries(Objects_aux);
        % get stats
        stats=  regionprops(L, 'Centroid', 'Area', 'Perimeter','BoundingBox');
        Perimeter = cat(1,stats.Perimeter);
        Area = cat(1,stats.Area);
        CircleMetric = (Perimeter.^2)./(4*pi*Area);  % circularity metric
        
        if Objects.NumObjects == 1 && CircleMetric(1) > 1.53 && CircleMetric(1) ~= 0 %tri
            bomb_detected = 1;
            app.BombDetectedLamp.Enable = 1; % just for the app
            app.BombDetectedLamp.Enable = 'on';
            bomb_center = stats(1).Centroid;
            accuracy = 50;
        end
        
        if Objects.NumObjects > 2
            % get the index of the object retangle and triangle if detected
            for i=1:Objects.NumObjects
                if CircleMetric(i) < 1.53 && CircleMetric(i) ~= 0 && aux2 == 0  %ret 
                    aux2 = 1;
                    idx_ret = i;
                end
                if CircleMetric(i) > 1.53 && CircleMetric(i) ~= 0 && aux1 == 0  %tri
                    aux1 = 1;
                    idx_tri = i;
                end
            end

            if ((idx_tri ~= 0) && (idx_ret ~=0))
                % verify if in the objects detected there are some retangle inside of a
                % triangle, if so we can assume that we found bomb
                if (stats(idx_tri).BoundingBox(1) < stats(idx_ret).BoundingBox(1)) &&   (stats(idx_tri).BoundingBox(2) < stats(idx_ret).BoundingBox(2))
                 if (stats(idx_tri).BoundingBox(3) > stats(idx_ret).BoundingBox(3)) &&   (stats(idx_tri).BoundingBox(4) > stats(idx_ret).BoundingBox(4))
                    bomb_detected = 1;
                    app.BombDetectedLamp.Enable = 1; % just for the app
                    app.BombDetectedLamp.Enable = 'on';
                    accuracy = 100;
                    % bomb centroid is the triangle centroid
                    bomb_center = stats(idx_tri).Centroid;
                 end
                end
            end
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