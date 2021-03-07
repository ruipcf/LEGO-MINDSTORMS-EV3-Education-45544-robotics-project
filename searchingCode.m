% searching for bombs function

% variables
wheelRadius = 55 / 2;
bomb_detected = 0;
vconst = 50;
angle = 0;
translation = 0;
numberRotations = 0.00;

while 1
    %aquisition of image (frame) and process it
    img = img_read();
    [bomb_detected,bomb_center,accuracy] = img_proc(img);
    while ~bomb_detected
        status_right = 0;
        status_left  = 0;
        
        fprintf('Starting \n')
        distance = readDistance(mysonicsensor); % 0 to 2.55
        resetRotationAngle(mygyrosensor)

        %aquisition of image (frame) and process it
        img = img_read();
        [bomb_detected,bomb_center,accuracy] = img_proc(img);
        if bomb_detected == 1
            break;
        end

        %% Rotate 45 degrees left
        if status_left == 0
            fprintf('Checking left \n')
            while angle > -45
                angle  = readRotationAngle(mygyrosensor);
                rightMotor.Speed = vconst;
                start(rightMotor);
                
                pressed=readTouch(mytouchsensor);
                if pressed == 1
                    pressed = 0;
                    fallback(leftMotor,rightMotor,mygyrosensor);
                    break;
                end
            end
            stop(rightMotor);
            pause(0.5)
            leftDistance = readDistance(mysonicsensor);

            %aquisition of image (frame) and process it
            img = img_read();
            [bomb_detected,bomb_center,accuracy] = img_proc(img);
            if bomb_detected == 1
                break;
            end
            
            fprintf('Back to center \n')
            while angle < 0
                angle = readRotationAngle(mygyrosensor);
                rightMotor.Speed = -vconst;
                start(rightMotor);
                
                pressed = readTouch(mytouchsensor);
                if pressed == 1
                    pressed = 0;
                    fallback(leftMotor,rightMotor,mygyrosensor);
                    break;
                end
            end
            stop(rightMotor);
        else 
            status_left = 0;
        end

        %% Rotate 45 degrees right
        if status_right == 0
            fprintf('Checking right \n')
            while angle < 45
                angle = readRotationAngle(mygyrosensor);
                leftMotor.Speed  = vconst;
                start(leftMotor);
                
                pressed = readTouch(mytouchsensor);
                if pressed == 1
                    pressed = 0;
                    fallback(leftMotor,rightMotor,mygyrosensor);
                    break;
                end
            end
            stop(leftMotor);
            pause(0.5)
            rightDistance = readDistance(mysonicsensor);

            %aquisition of image (frame) and process it
            img = img_read();
            [bomb_detected,bomb_center,accuracy] = img_proc(img);
            if bomb_detected == 1
                break;
            end

            fprintf('Back to center \n')
            while angle > 0
                angle = readRotationAngle(mygyrosensor);
                leftMotor.Speed  = -vconst;
                start(leftMotor);
                
                pressed = readTouch(mytouchsensor);
                if pressed == 1
                    pressed = 0;
                    fallback(leftMotor,rightMotor,mygyrosensor);
                    break;
                end
            end
            stop(leftMotor);
        else
            status_right = 0;
        end


        %% Move
        while true
            if distance > 0.50
                fprintf('Move forward \n')
                resetRotation(rightMotor)
                leftMotor.Speed  = vconst;
                rightMotor.Speed = vconst; 
                start(leftMotor);
                start(rightMotor);
                
                translation = 0;
                while translation < 200 %200mm = 20cm
                    angle = readRotationAngle(mygyrosensor);
                     if angle > 0
                        rightMotor.Speed = rightMotor.Speed + 1;
                        leftMotor.Speed  = vconst;
                     end
                     if angle < 0
                        leftMotor.Speed  = leftMotor.Speed + 1;
                        rightMotor.Speed = vconst;
                     end
                    rotation = readRotation(rightMotor);
                    numberRotations = double(rotation) / 360.0;
                    translation = numberRotations * (2*pi*wheelRadius);
                    
                    pressed = readTouch(mytouchsensor);
                    if pressed == 1
                        pressed = 0;
                        fallback(leftMotor,rightMotor,mygyrosensor);
                        break;
                    end
                end
                stop(leftMotor);
                stop(rightMotor); 
                break;
            end

            % rotate 180 if he hasnt distance to move forward
            if ((distance < 0.50) && (rightDistance < 0.30) && (leftDistance < 0.30))
                fprintf('Rotate 180 degrees \n')
                resetRotationAngle(mygyrosensor)
                while angle < 180
                    angle = readRotationAngle(mygyrosensor);
                    leftMotor.Speed  = vconst;
                    rightMotor.Speed = -vconst;
                    start(leftMotor);
                    start(rightMotor);
                    
                    pressed = readTouch(mytouchsensor);
                    if pressed == 1
                        pressed = 0;
                        fallback(leftMotor,rightMotor,mygyrosensor);
                        break;
                    end
                end 
                stop(leftMotor);
                stop(rightMotor);
                break;
            end

            % rotate to right if has distance to move
            if ((distance < 0.50) && (rightDistance > 0.30))
                fprintf('Go right \n')
                resetRotationAngle(mygyrosensor)
                while angle < 45
                    angle = readRotationAngle(mygyrosensor);
                    leftMotor.Speed  = vconst;
                    rightMotor.Speed = -vconst;
                    start(leftMotor);
                    start(rightMotor);
                    
                    pressed = readTouch(mytouchsensor);
                    if pressed == 1
                        pressed = 0;
                        fallback(leftMotor,rightMotor,mygyrosensor);
                        break;
                    end
                end 
                stop(leftMotor);
                stop(rightMotor);
                status_right = 1; % robot doens't have to check right again
                break;
            end

            % rotate to left if has distance to move
            if ((distance < 0.50) && (leftDistance > 0.30))
                fprintf('Go left \n')
                resetRotationAngle(mygyrosensor)
                while angle > -45
                    angle = readRotationAngle(mygyrosensor);
                    leftMotor.Speed  = -vconst;
                    rightMotor.Speed = vconst;
                    start(leftMotor);
                    start(rightMotor);
                    
                    pressed = readTouch(mytouchsensor);
                    if pressed == 1
                        pressed = 0;
                        fallback(leftMotor,rightMotor,mygyrosensor);
                        break;
                    end
                end 
                stop(leftMotor);
                stop(rightMotor);
                status_left = 1; % robot doens't have to check left again
                break;
            end
        end
    end

    %% Bomb detected / Move the robot to the bomb
    if bomb_detected == 1
        fprintf('Bomb detected \n')
        beep(myev3,1);
        stop(leftMotor);
        stop(rightMotor);

        distance = readDistance(mysonicsensor); % 0 to 2.55
        [y,x,nc] = size(img);
        
        while distance > 0.50
            %aquisition of image (frame) and process it
            img = img_read();
            [bomb_detected,bomb_center,accuracy] = img_proc(img)
            vconst = 30;
            xofsset = (x/2) - bomb_center(1);
            theta1  = (20*xofsset)/(x/2);
            
            distance = readDistance(mysonicsensor);
            theta2   = (5*(distance-0.5))/(2.55);

            leftMotor.Speed  = vconst  - theta1 + theta2;
            rightMotor.Speed = vconst  + theta1 + theta2;

            start(leftMotor);
            start(rightMotor);
        end
        stop(leftMotor);
        stop(rightMotor);
        vconst = 50;
        
        %% try to follow the yellow line
        intensity = readLightIntensity(mycolorsensor,'reflected');
        if intensity > 50 && intensity < 60
            while 1
                intensity = readLightIntensity(mycolorsensor,'reflected');
                theta1 = 10 * ((55 - intensity) / 100);

                leftMotor.Speed  = vconst  - theta1;
                rightMotor.Speed = vconst  + theta1;

              start(leftMotor);
              start(rightMotor);
            end
%         else     
%             a = 0;
%             while a < 2
%                 % Rotate 45 degrees left
%                 fprintf('Checking left to search yellow line \n')
%                 resetRotationAngle(mygyrosensor);
%                 angle = 0;
%                 while angle > -65 && (intensity < 50 || intensity > 60)
%                     angle = readRotationAngle(mygyrosensor);
%                     intensity = readLightIntensity(mycolorsensor,'reflected');
%                     rightMotor.Speed = vconst;
%                     start(rightMotor);

%                     pressed = readTouch(mytouchsensor);
%                     if pressed == 1
%                         pressed = 0;
%                         fallback(leftMotor,rightMotor,mygyrosensor);
%                         break;
%                     end
%                 end
%                 stop(rightMotor);
% 
%                 if (intensity < 50 || intensity > 60)
%                     while angle < 0
%                         angle = readRotationAngle(mygyrosensor);
%                         rightMotor.Speed = -vconst;
%                         start(rightMotor);

%                         pressed = readTouch(mytouchsensor);
%                         if pressed == 1
%                             pressed = 0;
%                             fallback(leftMotor,rightMotor,mygyrosensor);
%                             break;
%                         end
%                     end
%                     stop(rightMotor);
%                 end
% 
%             % Rotate 45 degrees right
%                 fprintf('Checking right to search yellow line \n')
%                 resetRotationAngle(mygyrosensor);
%                 angle = 0;
%                 while angle < 65 && (intensity < 50 || intensity > 60)
%                     angle = readRotationAngle(mygyrosensor);
%                     intensity = readLightIntensity(mycolorsensor,'reflected');
%                     leftMotor.Speed  = vconst;
%                     start(leftMotor);

%                     pressed = readTouch(mytouchsensor);
%                     if pressed == 1
%                         pressed = 0;
%                         fallback(leftMotor,rightMotor,mygyrosensor);
%                         break;
%                     end
%                 end
%                 stop(leftMotor);
% 
%                 if (intensity < 50 || intensity > 60)
%                     while angle > 0
%                         angle = readRotationAngle(mygyrosensor);
%                         intensity = readLightIntensity(mycolorsensor,'reflected');
%                         leftMotor.Speed  = -vconst;
%                         start(leftMotor);

%                         pressed = readTouch(mytouchsensor);
%                         if pressed == 1
%                             pressed = 0;
%                             fallback(leftMotor,rightMotor,mygyrosensor);
%                             break;
%                         end
%                     end
%                     stop(leftMotor);
%                 end
% 
%                 if (intensity < 50 || intensity > 60)
%                     fprintf('go front 5cm to search yellow line\n')
%                         resetRotation(rightMotor)
%                         resetRotationAngle(mygyrosensor);
%                         leftMotor.Speed = vconst;
%                         rightMotor.Speed = vconst; 
%                         start(leftMotor);
%                         start(rightMotor);
% 
%                         translation = 0;
%                         while translation < 30 && (intensity < 50 || intensity > 60) %30mm = 3cm
%                             angle = readRotationAngle(mygyrosensor);
%                             intensity = readLightIntensity(mycolorsensor,'reflected');
%                              if angle > 0
%                                 rightMotor.Speed = rightMotor.Speed + 1;
%                                 leftMotor.Speed  = vconst;
%                              end
%                              if angle < 0
%                                 leftMotor.Speed  = leftMotor.Speed + 1;
%                                 rightMotor.Speed = vconst;
%                              end
%                             rotation = readRotation(rightMotor);
%                             numberRotations = double(rotation) / 360.0;
%                             translation = numberRotations * (2*pi*wheelRadius);

%                             pressed = readTouch(mytouchsensor);
%                             if pressed == 1
%                                 pressed = 0;
%                                 fallback(leftMotor,rightMotor,mygyrosensor);
%                                 break;
%                             end
%                         end
%                         stop(leftMotor);
%                         stop(rightMotor); 
%                 end
%                 if intensity > 50 && intensity < 60
%                     break;
%                 else
%                     a = a + 1;
%                 end
%             end
%             if intensity > 50 && intensity < 60
%                 % follow yellow line
%                 while 1
%                     intensity = readLightIntensity(mycolorsensor,'reflected');
%                     theta1 = 10 * ((55 - intensity) / 100);
% 
%                     leftMotor.Speed  = vconst  - theta1;
%                     rightMotor.Speed = vconst  + theta1;
%                     
%                     % Procura imagem azul e vai ter com ela ate ficar a 15 cm
%                     [home_detected,home_center] = img_proc2(img);
%                     if home_detected == 1
%                         fprintf('Going home \n')
%                         distance = readDistance(mysonicsensor); % 0 to 2.55
%                         [y,x,nc] = size(img);
% 
%                         while distance > 0.50
%                             %aquisition of image (frame) and process it
%                             img = img_read();
%                             [home_detected,home_center] = img_proc2(img);
% 
%                             xofsset = (x/2) - home_center(1);
%                             theta1  = (10*xofsset)/(x/2);
% 
%                             distance = readDistance(mysonicsensor);
%                             theta2   = (10*(distance-0.5))/(2.55);
% 
%                             leftMotor.Speed  = vconst  - theta1 + theta2;
%                             rightMotor.Speed = vconst  + theta1 + theta2;
% 
%                             start(leftMotor);
%                             start(rightMotor);
%                         end
%                         stop(leftMotor);
%                         stop(rightMotor);
%                         fprintf('End of the program \n')
%                         break;
%                     end
%                 end
%             else
                % 180º rotation and go back
                fprintf('Rotation of 180 degrees and going back \n')
                resetRotationAngle(mygyrosensor);
                angle = 0;
                
                while angle < 180
                    angle = readRotationAngle(mygyrosensor);
                    leftMotor.Speed  = vconst;
                    rightMotor.Speed = -vconst;
                    start(leftMotor);
                    start(rightMotor);
                    
                    pressed = readTouch(mytouchsensor);
                    if pressed == 1
                        pressed = 0;
                        fallback(leftMotor,rightMotor,mygyrosensor);
                        break;
                    end
                end 
                stop(leftMotor);
                stop(rightMotor);
                
                % Search by blue rectangle and if robot finds it go to it
                % aquisition of image (frame) and process it
                img = img_read();
                [home_detected,home_center] = img_proc2(img);
                if home_detected == 1
                    fprintf('Going home \n')
                    distance = readDistance(mysonicsensor); % 0 to 2.55
                    [y,x,nc] = size(img);

                    while distance > 0.20
                        %aquisition of image (frame) and process it
                        img = img_read();
                        [home_detected,home_center] = img_proc2(img);
                        vconst = 30;
                        
                        xofsset = (x/2) - home_center(1);
                        theta1  = (20*xofsset)/(x/2);

                        distance = readDistance(mysonicsensor);
                        theta2   = (10*(distance-0.5))/(2.55);

                        leftMotor.Speed  = vconst  - theta1 + theta2;
                        rightMotor.Speed = vconst  + theta1 + theta2;

                        start(leftMotor);
                        start(rightMotor);
                    end
                    stop(leftMotor);
                    stop(rightMotor);
                    fprintf('End of the program \n')
                    break;
                else
                    % search righ and left
                    % Rotate 45 degrees left
                    resetRotationAngle(mygyrosensor)
                    angle = 0;
                    
                    fprintf('Checking left \n')
                    while angle > -45
                        angle  = readRotationAngle(mygyrosensor);
                        rightMotor.Speed = vconst;
                        start(rightMotor);

                        pressed=readTouch(mytouchsensor);
                        if pressed == 1
                            pressed = 0;
                            fallback(leftMotor,rightMotor,mygyrosensor);
                            break;
                        end
                    end
                    stop(rightMotor);

                    % aquisition of image (frame) and process it
                    img = img_read();
                    [home_detected,home_center] = img_proc2(img);

                    if ~home_detected
                        fprintf('Back to center \n')
                        while angle < 0
                            angle = readRotationAngle(mygyrosensor);
                            rightMotor.Speed = -vconst;
                            start(rightMotor);

                            pressed = readTouch(mytouchsensor);
                            if pressed == 1
                                pressed = 0;
                                fallback(leftMotor,rightMotor,mygyrosensor);
                                break;
                            end
                        end
                        stop(rightMotor);
                    end

                    if ~home_detected
                    % Rotate 45 degrees right
                        fprintf('Checking right \n')
                        while angle < 45
                            angle = readRotationAngle(mygyrosensor);
                            leftMotor.Speed  = vconst;
                            start(leftMotor);

                            pressed = readTouch(mytouchsensor);
                            if pressed == 1
                                pressed = 0;
                                fallback(leftMotor,rightMotor,mygyrosensor);
                                break;
                            end
                        end
                        stop(leftMotor);

                        % aquisition of image (frame) and process it
                        img = img_read();
                        [home_detected,home_center] = img_proc2(img);
                    end
                    
                    if ~home_detected
                        fprintf('Back to center \n')
                        while angle > 0
                            angle = readRotationAngle(mygyrosensor);
                            leftMotor.Speed  = -vconst;
                            start(leftMotor);

                            pressed = readTouch(mytouchsensor);
                            if pressed == 1
                                pressed = 0;
                                fallback(leftMotor,rightMotor,mygyrosensor);
                                break;
                            end
                        end
                        stop(leftMotor);
                    end
                        
                    if home_detected
                        fprintf('Going home \n')
                        distance = readDistance(mysonicsensor); % 0 to 2.55
                        [~,x,~] = size(img);

                        while distance > 0.20
                            %aquisition of image (frame) and process it
                            img = img_read();
                            [~,home_center] = img_proc2(img);

                            xofsset = (x/2) - home_center(1);
                            theta1  = (10*xofsset)/(x/2);

                            distance = readDistance(mysonicsensor);
                            theta2   = (10*(distance-0.5))/(2.55);

                            leftMotor.Speed  = vconst  - theta1 + theta2;
                            rightMotor.Speed = vconst  + theta1 + theta2;

                            start(leftMotor);
                            start(rightMotor);
                        end
                        stop(leftMotor);
                        stop(rightMotor);
                        fprintf('End of the program \n')
                        break;
                    else
                        break;
                    end  
                end
    end
end
%     end
% end