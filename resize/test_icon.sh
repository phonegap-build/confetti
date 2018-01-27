rm -rf _images;mkdir -p _images;cd _images

# ios

time convert ../statue.jpg -resize 1024x1024^ -gravity 'center' -write mpr:large +delete \
  mpr:large -geometry 1024x1024^ -crop 1024x1024+0+0 -set filename:size '%wx%h' -write 'ios-icon-%[filename:size].png' +delete \
  mpr:large -geometry 180x180^   -crop 180x180+0+0   -set filename:size '%wx%h' -write 'ios-icon-%[filename:size].png' +delete \
  mpr:large -geometry 167x167^   -crop 167x167+0+0   -set filename:size '%wx%h' -write 'ios-icon-%[filename:size].png' +delete \
  mpr:large -geometry 152x152^   -crop 152x152+0+0   -set filename:size '%wx%h' -write 'ios-icon-%[filename:size].png' +delete \
  mpr:large -geometry 120x120^   -crop 120x120+0+0   -set filename:size '%wx%h' -write 'ios-icon-%[filename:size].png' +delete \
  mpr:large -geometry 87x87^     -crop 87x87+0+0     -set filename:size '%wx%h' -write 'ios-icon-%[filename:size].png' +delete \
  mpr:large -geometry 80x80^     -crop 80x80+0+0     -set filename:size '%wx%h' -write 'ios-icon-%[filename:size].png' +delete \
  mpr:large -geometry 60x60^     -crop 60x60+0+0     -set filename:size '%wx%h' -write 'ios-icon-%[filename:size].png' +delete \
  mpr:large -geometry 58x58^     -crop 58x58+0+0     -set filename:size '%wx%h' -write 'ios-icon-%[filename:size].png' +delete \
  mpr:large -geometry 40x40^     -crop 40x40+0+0     -set filename:size '%wx%h'        'ios-icon-%[filename:size].png'

time convert ../statue.jpg -resize 192x192^ -gravity 'center' -write mpr:large +delete \
  mpr:large -geometry 192x192^ -crop 192x192+0+0 -set filename:size '%wx%h' -write 'android-icon-%[filename:size].png' +delete \
  mpr:large -geometry 144x144^ -crop 144x144+0+0 -set filename:size '%wx%h' -write 'android-icon-%[filename:size].png' +delete \
  mpr:large -geometry 96x96^   -crop 96x96+0+0   -set filename:size '%wx%h' -write 'android-icon-%[filename:size].png' +delete \
  mpr:large -geometry 72x72^   -crop 72x72+0+0   -set filename:size '%wx%h' -write 'android-icon-%[filename:size].png' +delete \
  mpr:large -geometry 48x48^   -crop 48x48+0+0   -set filename:size '%wx%h'        'android-icon-%[filename:size].png'

for i in *.png; do pngquant --speed 11 -f -o $i --strip $i; done

zip -rmq ./poop.zip ./

exit