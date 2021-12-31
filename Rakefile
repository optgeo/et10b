require './constants'

desc 'download mokuroku file'
task :mokuroku do
  sh "curl -O #{MOKUROKU_URL}"
end

desc 'prepare 256px tiles'
task :et256 do
  0.upto(MAXZOOM256) {|z|
    sh <<-EOS
zcat mokuroku.csv.gz | \
grep ^#{z}/ | \
parallel -j 4 --line-buffer ruby et256.rb {}
    EOS
  }
end

desc 'prepare 512px tiles'
task :et512 do
  sh "rake nodata" unless File.exist?(NODATA_PATH)
  0.upto(MAXZOOM512) {|z|
    sh <<-EOS
find #{ET256_DIR}/#{z} | grep webp$ | \
parallel -j #{J} --line-buffer ruby et512.rb {}
    EOS
  }
end

desc 'prepare a nodata file'
task :nodata do
  sh "ppmmake '#0186a0' 256 256 > #{TMP_DIR}/nodata.ppm"
end

