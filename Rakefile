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
end


