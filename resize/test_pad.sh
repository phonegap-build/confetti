rm -rf _images;mkdir -p _images;cd _images

# android landscape pad

time convert ../land.jpg -resize 1920x1280^ -gravity 'center' -write mpr:large -background 'red' +delete \
  mpr:large -geometry 1920x1280\> -extent 1920x1280 -set filename:size '%wx%h' -write 'android_l%[filename:size]p.png' +delete \
  mpr:large -geometry 1600x960\>  -extent 1600x960  -set filename:size '%wx%h' -write 'android_l%[filename:size]p.png' +delete \
  mpr:large -geometry 1280x720\>  -extent 1280x720  -set filename:size '%wx%h' -write 'android_l%[filename:size]p.png' +delete \
  mpr:large -geometry 800x480\>   -extent 800x480   -set filename:size '%wx%h' -write 'android_l%[filename:size]p.png' +delete \
  mpr:large -geometry 480x320\>   -extent 480x320   -set filename:size '%wx%h'        'android_l%[filename:size]p.png'

# android landscape crop

time convert ../land.jpg -resize 1920x1280^ -gravity 'center' -write mpr:large +delete \
  mpr:large -geometry 1920x1280^ -crop 1920x1280+0+0 -set filename:size '%wx%h' -write 'android_l%[filename:size]c.png' +delete \
  mpr:large -geometry 1600x960^  -crop 1600x960+0+0  -set filename:size '%wx%h' -write 'android_l%[filename:size]c.png' +delete \
  mpr:large -geometry 1280x720^  -crop 1280x720+0+0  -set filename:size '%wx%h' -write 'android_l%[filename:size]c.png' +delete \
  mpr:large -geometry 800x480^   -crop 800x480+0+0   -set filename:size '%wx%h' -write 'android_l%[filename:size]c.png' +delete \
  mpr:large -geometry 480x320^   -crop 480x320+0+0   -set filename:size '%wx%h'        'android_l%[filename:size]c.png' 

# android portrait pad

time convert ../land.jpg -resize 1280x1920^ -gravity 'center' -write mpr:large -background 'red' +delete \
  mpr:large -geometry 1280x1920\> -extent 1280x1920  -set filename:size '%wx%h' -write 'android_p%[filename:size]p.png' +delete \
  mpr:large -geometry 960x1600\>  -extent 960x1600   -set filename:size '%wx%h' -write 'android_p%[filename:size]p.png' +delete \
  mpr:large -geometry 720x1280\>  -extent 720x1280   -set filename:size '%wx%h' -write 'android_p%[filename:size]p.png' +delete \
  mpr:large -geometry 480x800\>   -extent 480x800    -set filename:size '%wx%h' -write 'android_p%[filename:size]p.png' +delete \
  mpr:large -geometry 320x480\>   -extent 320x480    -set filename:size '%wx%h'        'android_p%[filename:size]p.png'

# android portrait crop

time convert ../land.jpg -resize 1280x1920^ -gravity 'center' -write mpr:large +delete \
  mpr:large -geometry 1280x1920^ -extent 1280x1920+0+0  -set filename:size '%wx%h' -write 'android_p%[filename:size]c.png' +delete \
  mpr:large -geometry 960x1600^  -extent 960x1600+0+0   -set filename:size '%wx%h' -write 'android_p%[filename:size]c.png' +delete \
  mpr:large -geometry 720x1280^  -extent 720x1280+0+0   -set filename:size '%wx%h' -write 'android_p%[filename:size]c.png' +delete \
  mpr:large -geometry 480x800^   -extent 480x800+0+0    -set filename:size '%wx%h' -write 'android_p%[filename:size]c.png' +delete \
  mpr:large -geometry 320x480^   -extent 320x480+0+0    -set filename:size '%wx%h'        'android_p%[filename:size]c.png'

# ios portrait crop

time convert ../land.jpg -resize 2048x2732^ -gravity 'center' -write mpr:large +delete \
  mpr:large -geometry 2048x2732^ -crop 2048x2732+0+0 -set filename:size '%wx%h' -write 'ios_p%[filename:size]c.png' +delete \
  mpr:large -geometry 1668x2224^ -crop 1668x2224+0+0 -set filename:size '%wx%h' -write 'ios_p%[filename:size]c.png' +delete \
  mpr:large -geometry 1536x2048^ -crop 1536x2048+0+0 -set filename:size '%wx%h' -write 'ios_p%[filename:size]c.png' +delete \
  mpr:large -geometry 1125x2436^ -crop 1125x2436+0+0 -set filename:size '%wx%h' -write 'ios_p%[filename:size]c.png' +delete \
  mpr:large -geometry 1242x2208^ -crop 1242x2208+0+0 -set filename:size '%wx%h' -write 'ios_p%[filename:size]c.png' +delete \
  mpr:large -geometry 750x1136^  -crop 750x1136+0+0  -set filename:size '%wx%h' -write 'ios_p%[filename:size]c.png' +delete \
  mpr:large -geometry 640x1136^  -crop 640x1136+0+0  -set filename:size '%wx%h' 'ios_l%[filename:size]s.png'

# ios portrait pad

time convert ../land.jpg -resize 2048x2732^ -gravity 'center' -background 'red' -write mpr:large +delete \
  mpr:large -geometry 2048x2732\> -extent 2048x2732 -set filename:size '%wx%h' -write 'ios_p%[filename:size]p.png' +delete \
  mpr:large -geometry 1668x2224\> -extent 1668x2224 -set filename:size '%wx%h' -write 'ios_p%[filename:size]p.png' +delete \
  mpr:large -geometry 1536x2048\> -extent 1536x2048 -set filename:size '%wx%h' -write 'ios_p%[filename:size]p.png' +delete \
  mpr:large -geometry 1125x2436\> -extent 1125x2436 -set filename:size '%wx%h' -write 'ios_p%[filename:size]p.png' +delete \
  mpr:large -geometry 1242x2208\> -extent 1242x2208 -set filename:size '%wx%h' -write 'ios_p%[filename:size]p.png' +delete \
  mpr:large -geometry 750x1136\>  -extent 750x1136  -set filename:size '%wx%h' -write 'ios_p%[filename:size]p.png' +delete \
  mpr:large -geometry 640x1136\>  -extent 640x1136  -set filename:size '%wx%h' 'ios_p%[filename:size]p.png'

# ios landscape crop

time convert ../land.jpg -resize 2732x2048^ -gravity 'center' -write mpr:large +delete \
  mpr:large -geometry 2732x2048^ -crop 2732x2048+0+0 -set filename:size '%wx%h' -write 'ios_l%[filename:size]c.png' +delete \
  mpr:large -geometry 2224x1668^ -crop 2224x1668+0+0 -set filename:size '%wx%h' -write 'ios_l%[filename:size]c.png' +delete \
  mpr:large -geometry 2048x1536^ -crop 2048x1536+0+0 -set filename:size '%wx%h' -write 'ios_l%[filename:size]c.png' +delete \
  mpr:large -geometry 2436x1125^ -crop 2436x1125+0+0 -set filename:size '%wx%h' -write 'ios_l%[filename:size]c.png' +delete \
  mpr:large -geometry 2208x1242^ -crop 2208x1242+0+0 -set filename:size '%wx%h' -write 'ios_l%[filename:size]c.png' +delete \
  mpr:large -geometry 1136x750^  -crop 1136x750+0+0  -set filename:size '%wx%h' -write 'ios_l%[filename:size]c.png' +delete \
  mpr:large -geometry 1136x640^  -crop 1136x640+0+0  -set filename:size '%wx%h' 'ios_l%[filename:size]s.png'

# ios landscape pad

time convert ../land.jpg -resize 2732x2048^ -gravity 'center' -background 'red' -write mpr:large +delete \
  mpr:large -geometry 2732x2048\> -extent 2732x2048 -set filename:size '%wx%h' -write 'ios_l%[filename:size]p.png' +delete \
  mpr:large -geometry 2224x1668\> -extent 2224x1668 -set filename:size '%wx%h' -write 'ios_l%[filename:size]p.png' +delete \
  mpr:large -geometry 2048x1536\> -extent 2048x1536 -set filename:size '%wx%h' -write 'ios_l%[filename:size]p.png' +delete \
  mpr:large -geometry 2436x1125\> -extent 2436x1125 -set filename:size '%wx%h' -write 'ios_l%[filename:size]p.png' +delete \
  mpr:large -geometry 2208x1242\> -extent 2208x1242 -set filename:size '%wx%h' -write 'ios_l%[filename:size]p.png' +delete \
  mpr:large -geometry 1136x750\>  -extent 1136x750  -set filename:size '%wx%h' -write 'ios_l%[filename:size]p.png' +delete \
  mpr:large -geometry 1136x640\>  -extent 1136x640  -set filename:size '%wx%h' 'ios_l%[filename:size]p.png'

time for i in *.png; do pngquant --speed 11 -f -o $i --strip $i; done

zip -1 -r -m -q ./poop.zip ./

exit



