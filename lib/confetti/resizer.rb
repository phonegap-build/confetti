module Confetti
  module Resizer
    def create_icons dir, image, platforms

      if platforms.include? :ios
        cmd = "convert #{image} -gravity 'center' -resize 1024x1024^ -crop 1024x1024+0+0 -write mpr:large +delete \
                mpr:large -geometry 1024x1024^ -crop 1024x1024+0+0 -set filename:size '%wx%h' -write 'ios-icon-%[filename:size].png' +delete \
                mpr:large -geometry 180x180^   -crop 180x180+0+0   -set filename:size '%wx%h' -write 'ios-icon-%[filename:size].png' +delete \
                mpr:large -geometry 167x167^   -crop 167x167+0+0   -set filename:size '%wx%h' -write 'ios-icon-%[filename:size].png' +delete \
                mpr:large -geometry 152x152^   -crop 152x152+0+0   -set filename:size '%wx%h' -write 'ios-icon-%[filename:size].png' +delete \
                mpr:large -geometry 120x120^   -crop 120x120+0+0   -set filename:size '%wx%h' -write 'ios-icon-%[filename:size].png' +delete \
                mpr:large -geometry 87x87^     -crop 87x87+0+0     -set filename:size '%wx%h' -write 'ios-icon-%[filename:size].png' +delete \
                mpr:large -geometry 80x80^     -crop 80x80+0+0     -set filename:size '%wx%h' -write 'ios-icon-%[filename:size].png' +delete \
                mpr:large -geometry 60x60^     -crop 60x60+0+0     -set filename:size '%wx%h' -write 'ios-icon-%[filename:size].png' +delete \
                mpr:large -geometry 58x58^     -crop 58x58+0+0     -set filename:size '%wx%h' -write 'ios-icon-%[filename:size].png' +delete \
                mpr:large -geometry 40x40^     -crop 40x40+0+0     -set filename:size '%wx%h'        'ios-icon-%[filename:size].png'"
        SafeSys::safe_command(cmd, { dir: dir })
        File.open("#{dir}/config.xml", "a+") { |f| f << File.read(File.dirname(__FILE__) + '/templates/ios_icon.xml') }
      end

      if platforms.include? :android
        cmd = "convert #{image} -gravity 'center' -resize 192x192^ -crop 192x192+0+0 -write mpr:large +delete \
                mpr:large -geometry 192x192^ -crop 192x192+0+0 -set filename:size '%wx%h' -write 'android-icon-%[filename:size].png' +delete \
                mpr:large -geometry 144x144^ -crop 144x144+0+0 -set filename:size '%wx%h' -write 'android-icon-%[filename:size].png' +delete \
                mpr:large -geometry 96x96^   -crop 96x96+0+0   -set filename:size '%wx%h' -write 'android-icon-%[filename:size].png' +delete \
                mpr:large -geometry 72x72^   -crop 72x72+0+0   -set filename:size '%wx%h' -write 'android-icon-%[filename:size].png' +delete \
                mpr:large -geometry 48x48^   -crop 48x48+0+0   -set filename:size '%wx%h'        'android-icon-%[filename:size].png'"
        SafeSys::safe_command(cmd, { dir: dir })
        File.open("#{dir}/config.xml", "a+") { |f| f << File.read(File.dirname(__FILE__) + '/templates/android_icon.xml') }
      end

      if platforms.include? :windows
        cmd = "convert #{image} -gravity 'center' -resize 192x192^ -crop 192x192+0+0 -write mpr:large +delete \
                mpr:large -geometry 192x192^ -crop 192x192+0+0 -set filename:size '%wx%h' -write 'windows-icon-%[filename:size].png' +delete \
                mpr:large -geometry 144x144^ -crop 144x144+0+0 -set filename:size '%wx%h' -write 'windows-icon-%[filename:size].png' +delete \
                mpr:large -geometry 96x96^   -crop 96x96+0+0   -set filename:size '%wx%h' -write 'windows-icon-%[filename:size].png' +delete \
                mpr:large -geometry 72x72^   -crop 72x72+0+0   -set filename:size '%wx%h' -write 'windows-icon-%[filename:size].png' +delete \
                mpr:large -geometry 48x48^   -crop 48x48+0+0   -set filename:size '%wx%h'        'windows-icon-%[filename:size].png'"
        SafeSys::safe_command(cmd, { dir: dir })
        File.open("#{dir}/config.xml", "a+") { |f| f << File.read(File.dirname(__FILE__) + '/templates/windows_icon.xml') }
      end

    end
    module_function :create_icons

    def icon dir, image, platforms = [:ios, :windows, :android]

      FileUtils.rm_rf dir
      FileUtils.mkdir dir

      # generate icons and config.xml fragment
      create_icons(dir, image, platforms)

      # png optimise the files
      p SafeSys::safe_command("for i in *.png; do pngquant --verbose --speed 11 -f -o $i --strip $i; done", { dir: dir })

      # zip up files
      SafeSys::safe_command("zip -rmq ./icons.zip ./", { dir: dir })

      return "#{dir}/icons.zip"
    end
    module_function :icon

  end
end