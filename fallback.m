%% function executed when touch sensor is pressed
function [] = fallback(leftMotor,rightMotor,mygyrosensor)
    fprintf('pressed \n')
    stop(leftMotor);
    stop(rightMotor);
    resetRotationAngle(mygyrosensor);
    
    resetRotation(rightMotor);
    wheelRadius = 55 / 2;
    vconst = 50;
    translation = 0;
    
    while translation > -200 %200mm = 20cm
        angle = readRotationAngle(mygyrosensor);
        if angle > 0
           rightMotor.Speed = rightMotor.Speed - 1;
           leftMotor.Speed  = -vconst;
        end
        if angle < 0
           leftMotor.Speed  = leftMotor.Speed - 1;
           rightMotor.Speed = - vconst;
        end
        start(leftMotor);
        start(rightMotor);
        rotation = readRotation(rightMotor);
        numberRotations = double(rotation) / 360.0;
        translation = numberRotations * (2*pi*wheelRadius);
    end
end