require 'zip'




def zipit(userfolder)

    directory = "#{userfolder}/"
    zipfile_name = "#{userfolder}.zip"

    puts zipfile_name

    Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
        Dir[File.join(directory, '**', '**')].each do |file|
          zipfile.add(file.sub(directory, ''), file)
        end
    end

    `rm -rf #{directory}`
end