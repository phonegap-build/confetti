rm -rf _images;mkdir -p _images;cd _images

time convert ../sw.jpg -resize 2048x2732^ -write mpr:large +delete \
  mpr:large -geometry 2048x2732\>  -gravity 'north' -background 'red' -extent 2048x2732 -set filename:size '%wx%h' -write 'donkey1_%[filename:size]p.png' +delete \
  mpr:large -geometry 1280x1920\>  -background 'red' -extent 1280x1920  -set filename:size '%wx%h' -write 'donkey2_%[filename:size]p.png' +delete \
  mpr:large -geometry 960x1600\> -background 'red' -extent 960x1600 -set filename:size '%wx%h' -write 'donkey3_%[filename:size]p.png' +delete \
  mpr:large -geometry 720x1280\> -background 'red' -extent 720x1280 -set filename:size '%wx%h' -write 'donkey4_%[filename:size]p.png' +delete \
  mpr:large -geometry 480x800\> -background 'red' -extent 480x800 -set filename:size '%wx%h' -write 'donkey5_%[filename:size]p.png' +delete \
  mpr:large -geometry 320x480\> -background 'red' -extent 320x480 -set filename:size '%wx%h' 'donkey6_%[filename:size]p.png'

time convert ../sw.jpg -resize 2048x2732^ -write mpr:large +delete \
  mpr:large -geometry 2048x2732^  -gravity 'north' -background 'red' -set filename:size '%wx%h' -write 'donkey1_%[filename:size]s.png' +delete \
  mpr:large -geometry 1280x1920^  -background 'red' -crop 1280x1920+0+0 -set filename:size '%wx%h' -write 'donkey2_%[filename:size]s.png' +delete \
  mpr:large -geometry 960x1600^ -background 'red' -crop 960x1600+0+0 -set filename:size '%wx%h' -write 'donkey3_%[filename:size]s.png' +delete \
  mpr:large -geometry 720x1280^ -background 'red' -crop 720x1280+0+0 -set filename:size '%wx%h' -write 'donkey4_%[filename:size]s.png' +delete \
  mpr:large -geometry 480x800^ -background 'red' -crop 480x800+0+0 -set filename:size '%wx%h' -write 'donkey5_%[filename:size]s.png' +delete \
  mpr:large -geometry 320x480^ -background 'red' -crop 320x480+0+0  -set filename:size '%wx%h' 'donkey6_%[filename:size]s.png' 

time convert ../sw.jpg -resize 2048x2732^ -write mpr:large +delete \
  mpr:large -gravity 'north' -background 'red' -crop 2048x2732+0+0 -set filename:size '%wx%h' -write 'donkey1_%[filename:size]c.png' +delete \
  mpr:large -background 'red' -crop 1280x1920+0+0 -set filename:size '%wx%h' -write 'donkey2_%[filename:size]c.png' +delete \
  mpr:large -background 'red' -crop 960x1600+0+0 -set filename:size '%wx%h' -write 'donkey3_%[filename:size]c.png' +delete \
  mpr:large -background 'red' -crop 720x1280+0+0 -set filename:size '%wx%h' -write 'donkey4_%[filename:size]c.png' +delete \
  mpr:large -background 'red' -crop 480x800+0+0 -set filename:size '%wx%h' -write 'donkey5_%[filename:size]c.png' +delete \
  mpr:large -background 'red' -crop 320x480+0+0 -set filename:size '%wx%h' 'donkey6_%[filename:size]c.png' 

time for i in donkey*; do pngquant --speed 11 -f -o $i --strip $i; done