#!/usr/bin/env bash

#save in the FG aircraft directory for easy conversion of developing model
#remember to save the texture files to the FGFS airplane levery directory
#convert obj to ac and adjust texture directory

#location of the obj model
input=/home/jeff/models/3d_models/ships/Kathryn/kathryn.obj
#location for the converted ac model
output=/home/jeff/FlightGear/Aircraft/Kathryn/Models/Kathryn.ac
echo "CONVERTING:";
echo $input;
echo $output;

#execute the conversion
ruby /home/jeff/models/Remodel/convert2.rb $input $output;

#change texture path in ac file to FGFS airplane livery directory
echo 'EDITING TEXTURE PATH:'
find $output -type f -exec sed -i 's/texture "/texture "Liveries\//g' {} \;

echo "FINISHED CONVERSION.";
