require './constants'
zxy = ARGV[0].split('/').map{|v| v.to_i}[1..3]
dst_dir = "#{ET512_DIR}/#{zxy[0]}/#{zxy[1]}"
system "mkdir -p #{dst_dir}"
dst_path = "#{dst_dir}/#{zxy[2]}.webp"
if SKIP && File.exist?(dst_path)
  print "skipping #{dst_path} (#{File.size(dst_path)}).\n"
  exit 0
end
z = zxy[0] + 1
x = zxy[1] * 2
y = zxy[2] * 2

def path(z, x, y)
  src = "#{ET256_DIR}/#{z}/#{x}/#{y}.webp"
  dst = "#{TMP_DIR}/#{z}-#{x}-#{y}.ppm"
  if File.exist?(src)
    system <<-EOS
dwebp -ppm #{src} -o #{dst}
    EOS
    dst
  else
    NODATA_PATH
  end
end

system <<-EOS
pnmcat -leftright \
#{path(z, x, y)} #{path(z, x + 1, y)} \
> #{TMP_DIR}/#{zxy.join('-')}-top.ppm
EOS

system <<-EOS
pnmcat -leftright \
#{path(z, x, y + 1)} #{path(z, x + 1, y + 1)} \
> #{TMP_DIR}/#{zxy.join('-')}-bottom.ppm
EOS

system <<-EOS
pnmcat -topbottom \
#{TMP_DIR}/#{zxy.join('-')}-top.ppm \
#{TMP_DIR}/#{zxy.join('-')}-bottom.ppm \
> #{TMP_DIR}/#{zxy.join('-')}.ppm
EOS

system <<-EOS
cwebp -lossless -z #{Z_CWEBP} \
#{TMP_DIR}/#{zxy.join('-')}.ppm \
-o #{dst_path} 2>&1
EOS

system "rm #{TMP_DIR}/#{zxy.join('-')}*"

2.times {|i|
  2.times {|j|
    path = "#{TMP_DIR}/#{z}-#{x + i}-#{y + j}.ppm"
    system "rm #{path}" if File.exist?(path)
  }
}
