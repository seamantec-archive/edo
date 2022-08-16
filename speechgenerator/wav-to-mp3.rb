wav_dir = "/Users/pepusz/Downloads/mono-zero"
mp3_dir =  "/Users/pepusz/Downloads/mono-zero-mp3"
files = Dir.entries(wav_dir)
files.each do |f|
  if(f.match(".wav"))
        `lame  -m m -h --cbr -b 24 --resample 44 #{wav_dir}/#{f} #{mp3_dir}/#{f.gsub(".wav", "")}.mp3 `
  end

end