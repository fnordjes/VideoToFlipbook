VideoToFlipbook
===============

A simple bash script to create a flipbook from a video file.

Requires 'avconv' and 'ImageMagick'.

Usage
=====

```sh
$ ./VideoToFlipBook.bash 

Create printable document to tinker a flipbook. Requires avconv convert montage.
DIN A4 is used as the paper format. Print resolution is set to 300 dpi.

Usage: ./VideoToFlipBook.bash [-h] FILE [-i <IN>] [-o <OUT>] [-f <FRAMERATE>]
    -h, --help    Show this help message and exit
    -i, --in      Time of the video to start with (defaults to 00:00:00 and can
                  be given in format "hh:mm:ss" or as seconds only)
    -t, --time    Duration of the video to convert (defaults to ten seconds)
    -f, --fps     Number of frames to capture per second (defaults to 5)

```


Lessons learned after the first attempt
=======================================

* Use a video with bright and contrasty colours. The laser printed flipbook
  turned out a little too dark for my taste.
* The border to hold the flipbook should be adjusted to the paper thickness.
  I used 160 gram/squaremeter paper with 100% border which was two much.
* Fast movements are not very well captured.


To Do
=====

* Create a preview of the flipbook as animated gif.
* Make the size configureable.
* ...
