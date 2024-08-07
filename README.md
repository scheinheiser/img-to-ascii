# img-to-ascii
A small image to ascii converter. It doesn't work very well with large images, but resizing it to something around 200x200 or less should be fine. 

It has all of the limitations that the zigimg dependency has (e.g. it won't work with jpeg files).

## Usage
Clone the repo:
```
git clone https://github.com/scheinheiser/img-to-ascii
```
On line 93, replace the file path with the *absolute* path to your image.

On line 34, replace the second value in `@mod` with the width of the image.

Once done, run:
`zig build`
In your terminal, and then run the executable in `zig-out/bin`.
