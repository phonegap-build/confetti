rm -rf _images;mkdir -p _images;cd _images

# android portrait crop

time convert ../splash.png -resize 1280x1920^ -gravity 'center' -write mpr:large +delete \
  mpr:large -geometry 1280x1920^ -crop 1280x1920+0+0 -set filename:size '%wx%h' -write 'android_p%[filename:size]c.png' +delete \
  mpr:large -geometry 960x1600^  -crop 960x1600+0+0  -set filename:size '%wx%h' -write 'android_p%[filename:size]c.png' +delete \
  mpr:large -geometry 720x1280^  -crop 720x1280+0+0  -set filename:size '%wx%h' -write 'android_p%[filename:size]c.png' +delete \
  mpr:large -geometry 480x800^   -crop 480x800+0+0   -set filename:size '%wx%h' -write 'android_p%[filename:size]c.png' +delete \
  mpr:large -geometry 320x480^   -crop 320x480+0+0   -set filename:size '%wx%h'        'android_p%[filename:size]c.png'

# android landscape crop

time convert ../splash.png -resize 1920x1280^ -gravity 'center' -write mpr:large +delete \
  mpr:large -geometry 1920x1280^ -crop 1920x1280+0+0 -set filename:size '%wx%h' -write 'android_l%[filename:size]c.png' +delete \
  mpr:large -geometry 1600x960^  -crop 1600x960+0+0  -set filename:size '%wx%h' -write 'android_l%[filename:size]c.png' +delete \
  mpr:large -geometry 1280x720^  -crop 1280x720+0+0  -set filename:size '%wx%h' -write 'android_l%[filename:size]c.png' +delete \
  mpr:large -geometry 800x480^   -crop 800x480+0+0   -set filename:size '%wx%h' -write 'android_l%[filename:size]c.png' +delete \
  mpr:large -geometry 480x320^   -crop 480x320+0+0   -set filename:size '%wx%h'        'android_l%[filename:size]c.png' 

# ios portrait crop

time convert ../splash.png -resize 2048x2732^ -gravity 'center' -write mpr:large +delete \
  mpr:large -geometry 2048x2732^ -crop 2048x2732+0+0 -set filename:size '%wx%h' -write 'ios_p%[filename:size]c.png' +delete \
  mpr:large -geometry 1668x2224^ -crop 1668x2224+0+0 -set filename:size '%wx%h' -write 'ios_p%[filename:size]c.png' +delete \
  mpr:large -geometry 1536x2048^ -crop 1536x2048+0+0 -set filename:size '%wx%h' -write 'ios_p%[filename:size]c.png' +delete \
  mpr:large -geometry 1125x2436^ -crop 1125x2436+0+0 -set filename:size '%wx%h' -write 'ios_p%[filename:size]c.png' +delete \
  mpr:large -geometry 1242x2208^ -crop 1242x2208+0+0 -set filename:size '%wx%h' -write 'ios_p%[filename:size]c.png' +delete \
  mpr:large -geometry 750x1136^  -crop 750x1136+0+0  -set filename:size '%wx%h' -write 'ios_p%[filename:size]c.png' +delete \
  mpr:large -geometry 640x1136^  -crop 640x1136+0+0  -set filename:size '%wx%h'        'ios_l%[filename:size]c.png'

# ios landscape crop

time convert ../splash.png -resize 2732x2048^ -gravity 'center' -write mpr:large +delete \
  mpr:large -geometry 2732x2048^ -crop 2732x2048+0+0 -set filename:size '%wx%h' -write 'ios_l%[filename:size]c.png' +delete \
  mpr:large -geometry 2224x1668^ -crop 2224x1668+0+0 -set filename:size '%wx%h' -write 'ios_l%[filename:size]c.png' +delete \
  mpr:large -geometry 2048x1536^ -crop 2048x1536+0+0 -set filename:size '%wx%h' -write 'ios_l%[filename:size]c.png' +delete \
  mpr:large -geometry 2436x1125^ -crop 2436x1125+0+0 -set filename:size '%wx%h' -write 'ios_l%[filename:size]c.png' +delete \
  mpr:large -geometry 2208x1242^ -crop 2208x1242+0+0 -set filename:size '%wx%h' -write 'ios_l%[filename:size]c.png' +delete \
  mpr:large -geometry 1136x750^  -crop 1136x750+0+0  -set filename:size '%wx%h' -write 'ios_l%[filename:size]c.png' +delete \
  mpr:large -geometry 1136x640^  -crop 1136x640+0+0  -set filename:size '%wx%h'        'ios_l%[filename:size]c.png'

time for i in *.png; do pngquant --speed 11 -f -o $i --strip $i; done

exit



