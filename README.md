## Welcome to Remodel!

Remodel is a Ruby command line script for converting *.obj models to *.ac format. You must have Ruby installed and running on your computer. See ruby-lang.org for more information on installing Ruby.

A web GUI was added to Remodel to make it easier when extracting UV coordinates to *.svg files. This functionality was added when I was experimenting with using computer 3d models to generate card models. While this feature has long been surpassed by other programs I still use Remodel when creating models for FlightGear which uses *.ac as a standard file format.

- Browse for a *.obj or *.ac model

- If extracting UVs, select stroke and fill options.

- Select your conversion option and click 'Do it!'

- Download the converted file to your download location.

- Remodel will cache the original and converted models. Click 'clear cache' to delete the cached versions.

- Remember to exit Remodel using the button in the upper right corner. If you close the browser first, Remodel will continue to run in the background.

To use Remodel from the command line type:

- ruby [path]convert.rb input_file output_file

You can also use convert2.rb if you need to change the texture locations in the *.ac file to another directory (typically the Livery directory in a FlightGear aircraft director).

A sample *.sh file is provided if you repeatedly convert a model (common when developing the model and you want to view it in FlightGear). Just change the script to point to your models.
