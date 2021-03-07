%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
%%%%%%%%%%          Trabalho Prático UC -  Robotica        %%%%%%%%%%%%%%%%       
%%%%%%%%%%                                                 %%%%%%%%%%%%%%%%   
%%%%%%%%%%            17608     -----     17618            %%%%%%%%%%%%%%%% 
%%%%%%%%%%                                                 %%%%%%%%%%%%%%%% 
%%%%%%%%%%               Kit LEGO EV3 45544                %%%%%%%%%%%%%%%% 
%%%%%%%%%%              Bomb detector Robot                %%%%%%%%%%%%%%%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%      

clear all
close all
clc

% connection by USB
myev3 = legoev3('USB');
batteryLevel = myev3.BatteryLevel();

% sensors
mysonicsensor = sonicSensor(myev3);
mygyrosensor  = gyroSensor(myev3);
mycolorsensor = colorSensor(myev3);
mytouchsensor = touchSensor(myev3);

% motors
leftMotor  = motor(myev3,'B');
rightMotor = motor(myev3,'C');

if batteryLevel >= 10
    beep(myev3,1);
    searchingCode();
else
    fprintf('Warning! Low battery!')
    beep(myev3,2)
end