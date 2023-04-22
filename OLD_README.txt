RELEASE: 20070311  -- added default material attributes for *.ac output
RELEASE: 20070217  -- initial release
====================================================
ABOUT THIS PROGRAM
Remodel is a command line Ruby script to convert *.obj models to *.ac format. It was primarily written to convert *.obj models exported from Wings3D (http://www.wings3d.com) in order to use them in FlightGear (http://www.flightgear.org). Other *.obj models should work OK. Not all *.obj characteristics are accounted for because *.ac format does not handle them.

By default, material texture file names, if present in the model, will be changed to use an 'rgb' extension. This can be overridden by using the -ext parameter. Note that this program will not change the texture files themselves. You'll need to do that yourself. Also, if for some perverse reason you insist on using *.bmp graphic files in FG, note that the *.bmp files have a reversed vertical axis. So, you'll need to flip your images in the vertical dimension to use them.

The input model file name must have a 'obj' extension. The output file name must have either an 'ac' or an 'obj' extension. (Converting *.obj to *.obj sometimes helps with debugging.) The materials definition *.mtl file should be in the same directory as the *.obj file.

While not absolutely essential, it is helpful if your *.obj model is triangulated before converting. The conversion program does no tessellation, but FlightGear (well, plib, I think) does—sometimes with erroneous results. Also note that typically in *.obj format the x vector is longitudinal, z is transverse and y is vertical. In *.ac format x is longitudinal, z is vertical and y is transverse. Wings3D has an *obj export option to switch the y and z axes. Other modeling applications may not have this feature and you'll need to roll your model 90 degrees.

====================================================
USAGE

If convert.rb is executable and calls the Ruby interpreter:
	[path]convert.rb [path]input_model.obj [path]output_model.ac [-ext=xxx]

If you need to explicitly call the Ruby interpreter:
	[path]ruby [path]convert.rb [path]input_model.obj [path]output_model.ac [-ext=xxx]

====================================================
PREREQUISITES
You must have the Ruby interpreter installed and running in your environment.

http://www.ruby-lang.org

====================================================
INSTALLATION
Uncompress the files. You may need to edit the shebang line in convert.rb to point to your Ruby installation. In Windows, you'll want to associate the 'rb' file extension with the Ruby interpreter.

====================================================
FILES                           DESCRIPTION
./convert.rb                    main program
./model.rb                      internal representation of 3d model
./3d_formats/obj.rb             imports/exports *.obj format
./3d_formats/ac.rb              exports *.ac format


====================================================
LICENSE
This software is copyrighted free software by Jeffery S. Koppe <kugelfang@operamail.com>. You can redistribute it and/or modify it under either the terms of the GPL, or the conditions below:

1. You may make and give away verbatim copies of the source form of the software without restriction, provided that you duplicate all of the original copyright notices and associated disclaimers.

2. You may modify your copy of the software in any way, provided that you do at least ONE of the following:

 a) place your modifications in the Public Domain or otherwise make them Freely Available, such as by posting said modifications to Usenet or an equivalent medium, or by allowing the author to include your modifications in the software.

 b) use the modified software only within your corporation or organization.

 c) rename any non-standard executables so the names do not conflict with standard executables, which must also be provided.

 d) make other distribution arrangements with the author.

3. You may distribute the software in object code or executable form, provided that you do at least ONE of the following:

 a) distribute the executables and library files of the software, together with instructions (in the manual page or equivalent) on where to get the original distribution.

 b) accompany the distribution with the machine-readable source of the software.

 c) give non-standard executables non-standard names, with instructions on where to get the original software distribution.

 d) make other distribution arrangements with the author.

4. You may modify and include part of the software into any other software (possibly commercial).  But some files in the distribution may not be written by the original author, so that they are not under these terms.

5. The scripts and library files supplied as input to or produced as output from the software do not automatically fall under the copyright of the software, but belong to whomever generated them, and may be sold commercially, and may be aggregated with this software.

6. THIS SOFTWARE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
