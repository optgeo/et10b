require './constants'
require 'stringio'
require 'pnm'

def transcode(src_image)
  pixels = src_image.pixels
  src_image.height.times {|j|
    src_image.width.times {|i|
      pixel = pixels[j][i]
      d = pixel[0] * 2 ** 16 +
        pixel[1] * 2 ** 8 +
        pixel[2]
      h = (d < 2 ** 23) ? d : d - 2 ** 24
      if h == - (2 ** 23)
        h = 0
      else
        h *= 0.01
      end
      box = sprintf('%06x', (10 * (h + 10000)).round)
      r = box[0..1].to_i(16)
      g = box[2..3].to_i(16)
      b = box[4..5].to_i(16)
      pixels[j][i] = [r, g, b]
      #print "#{pixel} -> #{sprintf('%.2f', h)}m -> \
#{pixels[j][i]}\n" unless h == 0
    }
  }
  PNM.create(pixels)
end

def write(zxy, dst_image)
  ppm_path = "#{TMP_DIR}/#{zxy.join('-')}.ppm"
  webp_path = "#{ET256_DIR}/#{zxy.join('/')}.webp"

  dst_image.write(ppm_path)
  system <<-EOS
mkdir -p #{ET256_DIR}/#{zxy[0]}/#{zxy[1]}; \
pnmtopng #{ppm_path} | \
cwebp -lossless -z 0 -o #{webp_path} -- - 2>&1 ; \
rm #{ppm_path}
  EOS
end

zxy = ARGV[0].split(',')[0].split('/').map {|v| v.to_i}
p zxy
webp_path = "#{ET256_DIR}/#{zxy.join('/')}.webp"
if File.exist?(webp_path)
  p 'skip'
else
  src_image = PNM.read(StringIO.new(
    `curl #{SRC_BASE_URL}/#{zxy.join('/')}.png | pngtopnm`
  ))
  dst_image = transcode(src_image)
  write(zxy, dst_image)
end

