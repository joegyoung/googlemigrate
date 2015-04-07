class GoogleFileAPI
    def initialize(initarray)
      #pp initarray[0].class.to_s
      case initarray[0].class.to_s
         when 'String'
          #puts "String"

          #pp initarray[0]
          #pp initarray[1]

           n = GoogleAPI.new(initarray[0])
          client_id = 'https://www.googleapis.com/auth/drive'
          client = n.build_client(initarray[0],client_id)
          drive = client.discovered_api('drive', 'v2')
          api_result = client.execute(
            :api_method => drive.files.get,
            :parameters => { 'fileId' => initarray[1] }
           )
          @drive_file_record = api_result.data
          @file_owner = n #client


          #puts "$$$$$$$$$$$$$ file_owner"
          #pp @file_owner
          #puts "drive_file_record"
          #pp @drive_file_record

        when 'GoogleAPI'
          #puts "GOOG"


          #puts initarray[0].drive_client
          @drive_file_record = initarray[1]
          @file_owner = initarray[0]


          #puts "$$$$$$$$$$$$$  file_owner"
          #pp @file_owner
          #puts "drive_file_record"
          #pp @drive_file_record
          
        end
        #pp details

    end

    def ownername
       @file_owner.info.primaryEmail
    end

    def title
       @drive_file_record.title
    end


    def refetch
      client_id = 'https://www.googleapis.com/auth/drive'
      client = @file_owner.build_client(ownername,client_id)
      drive = client.discovered_api('drive', 'v2')
      api_result = client.execute(
            :api_method => drive.files.get,
            :parameters => { 'fileId' => id }
           )
          @drive_file_record = api_result.data
    end



    def details
       @drive_file_record
    end

    def show_all
        @drive_file_record.to_hash
    end

    def download_link()
      show_link(true)
    end


    def mimeType
      @drive_file_record.mimeType
    end

    def id 
      @drive_file_record.id
    end


    def version 
      @drive_file_record.version
    end



    def show_link(ok_to_download=false)
      ok_to_download = ok_to_download || false
      #pp title

      #begin

        #pp @drive_file_record.mimeType
        case @drive_file_record.mimeType
          when "application/vnd.google-apps.document"
            downloadUrl = @drive_file_record['exportLinks']['application/vnd.openxmlformats-officedocument.wordprocessingml.document']
            downloadfileextension = ".docx"


            download(downloadUrl,downloadfileextension) #if ok_to_download
            #{}"-->document"
          when "application/vnd.google-apps.spreadsheet"
            downloadUrl = @drive_file_record['exportLinks']['application/vnd.openxmlformats-officedocument.spreadsheetml.sheet']
            downloadfileextension = ".xlsx"
            download(downloadUrl,downloadfileextension) #if ok_to_download
            #{}"-->spreadsheet"
          when "application/vnd.google-apps.presentation"
            downloadUrl = @drive_file_record['exportLinks']['application/vnd.openxmlformats-officedocument.presentationml.presentation']
            downloadfileextension = ".pptx"
            download(downloadUrl,downloadfileextension) #if ok_to_download
            #{}"-->presentation"
          when "application/vnd.google-apps.drawing"
            downloadUrl = @drive_file_record['exportLinks']['image/svg+xml']
            downloadfileextension = ".svg"
            download(downloadUrl,downloadfileextension) #if ok_to_download
            #{}"-->drawing"
          when "application/vnd.google-apps.folder"
            puts "Just a folder: #{title}"
            $logging.log(ownername,"INFO","DOWNLOAD","[#{ownername}] INGORED FOLDER: #{title}")

            #{}"-->folder"
          when "application/vnd.google-apps.form"

            if details["copyable"] == true
              if $logging.dont_have_file(id,version) == true 
              #=begin





                          shareuser = $configuration["googleshareuser"] || "<emailaddress>"

                          share(shareuser,"writer")
                          sharedfile = GoogleFileAPI.new([shareuser,id])


                          if $logging.file_check_for_current_location(id).nil? == false
                            pp $logging.file_check_for_current_location(id)
                            sharedfile.delete_file( $logging.file_check_for_current_location(id)  )
                          end



                          newfile = sharedfile.copy("[#{ownername}] #{title}")
                          
                          remove_permission(shareuser)

                          refetch()

                          puts " # SHARED #{@drive_file_record.mimeType}"
                          $logging.push("SAVING #{ownername} - <span style='blue'>#{title}</span> ")  # [#{where}/#{filename}]
                          $logging.file(id,ownername,mimeType,title,version,"#{newfile.id}")
                          $logging.log(ownername,"INFO","SHARED","[#{ownername}] SHARED: #{newfile.id}")

              #=end
              else

                          $logging.push("<span style='red'>SKIPPING - ALREADY HAVE #{title}</span>")
                          puts "@@@@@ SKIPPING - ALREADY HAVE #{ownername}, #{id}, #{title}"
                          $logging.log(ownername,"INFO","SAVE","SKIPPING - ALREADY HAVE #{title}")


              end
            else # end of copy-if
                          puts " # DENIED SHARING #{title}  #{@drive_file_record.mimeType}"
                          $logging.push("DENIED SHARING #{ownername} - <span style='blue'>#{title}</span> ")  # [#{where}/#{filename}]
                         # $logging.file(id,ownername,mimeType,title,version,"#{newfile.id}")
                          $logging.log(ownername,"WARN","SHARED","[#{ownername}] DENIED SHARED: #{id}")
            end
          when /application\/vnd.google-apps.drive-sdk/

            $logging.file(id,ownername,mimeType,title,version,@drive_file_record.alternateLink)
            #@drive_file_record.alternateLink

            $logging.log(ownername,"INFO","SAVE","[#{ownername}] Got details for  drive-sdk: [#{id}] #{title}")
            $logging.push("IGNORE -------------------------------> #{ownername} - #{title} ")
            puts "drive-sdk!!!!!!#{@drive_file_record.alternateLink}"
            #pp  details.to_hash


            #sleep 4

          when "application/vnd.google-apps.script"
            $logging.file(id,ownername,mimeType,title,version,@drive_file_record.alternateLink)
            $logging.log(ownername,"INFO","SAVE","[#{ownername}] Got details for  script: [#{id}] #{title}")
            $logging.push("IGNORE -------------------------------> #{ownername} - #{title} ")
            puts "script!!!!!!#{@drive_file_record.alternateLink}"
            #pp  details.to_hash


            #sleep 4


          else


#pp  details.to_hash
           # sleep 12



            uri = @drive_file_record.downloadUrl



            ext = File.extname(title)
            basename = File.basename( uri, ext )  
            download(uri,ext) if ok_to_download

            #puts " # Regular file  #{title} #{@drive_file_record.mimeType}"

           # puts "###### ELSE! !!!! #{id}, #{title} #{File.extname(title)}######"


        end
=begin
        #rescue  

    $logging.push("#{ownername} #{title} ###### WARNING! I had to be rescued ######")
    $logging.log(ownername,"ERROR","download","Errored on #{title}")

     puts "###### WARNING! I had to be rescue: '#{title}'' ######"
     pp @drive_file_record.mimeType
     pp downloadUrl
     pp downloadfileextension
     pp @drive_file_record.exportLinks.to_hash


      end
=end

    end

    def download(downloadUrl,downloadfileextension)

      if $logging.dont_have_file(id,version) == true

            n = @file_owner
            client = n.drive_client

            where = $workingdirectory + ownername
            #filename = id + "-" + title.tr('!','').tr('/',' ') + downloadfileextension
            filename = id + downloadfileextension

            $logging.push("SAVING #{ownername} - <span style='blue'>#{title}</span> ")  # [#{where}/#{filename}]
            
            puts "#{ownername},#{mimeType},#{where}/#{filename}"


      begin


            Dir.mkdir(where) unless File.exists?(where)


            uri = downloadUrl
            begin
            result = client.execute(:uri => uri)

              # md5 =  Digest::MD5.hexdigest result.body 
            $logging.file(id,ownername,mimeType,title,version,"#{where}/#{filename}")
            $logging.log(ownername,"INFO","DOWNLOAD","#{where}/#{filename}")

            rescue
              $logging.push("<span style='red'>URI:#{uri}</span> ")
                $logging.push("<span style='red'>ERROR - DOWNLOAD #{title}</span> #{id}")
                $logging.push("<span style='red'>URI:#{url}</span> ")
              $logging.log(ownername,"ERROR","DOWNLOAD","Can't DOWNLOAD #{where}/#{filename}")
              puts "@@@@@ i was not able to download !!!!!!"
            end
            external_file = where + "/" + filename
            File.open(external_file, 'w') { |file| file.write(result.body) }
            #if downloadfileextension == ".docx"
            #  doc = Docx::Document.open(external_file)
            #  doc.paragraphs.reverse.each do |p| 
            #    $logging.push("<b>#{p}</b>") if p !=""
            #  end
            #end


            rescue
                $logging.push("<span style='red'>ERROR - SAVE #{title}</span>")
              puts "@@@@@ i was not able to save  to #{id} #{external_file}"
              $logging.log(ownername,"ERROR","SAVE","Can't SAVE #{where}/#{filename}")

            end
          else

            $logging.push("<span style='red'>SKIPPING - ALREADY HAVE #{title}</span>")
            puts "@@@@@ SKIPPING - ALREADY HAVE #{ownername}, #{id}, #{title}"
            $logging.log(ownername,"INFO","SAVE","SKIPPING - ALREADY HAVE #{title}")
        end

    end




def show_links
 @drive_file_record.data


end

    def show_links2

if @drive_file_record.downloadUrl
      puts "YYYYES"
           @drive_file_record.downloadUrl
else
  begin
  pp @drive_file_record.exportLinks.to_hash
  rescue
    puts "STOP"
    pp @drive_file_record
  end
end

    end




###
###
###


def insert_o(title, description, mime_type, file_name)

convertiable = { 'application/vnd.google-apps.document' => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  "application/vnd.google-apps.spreadsheet" => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  "application/vnd.google-apps.presentation" => 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
  "application/vnd.google-apps.drawing" => 'image/svg+xml'
}

if mime_type =~ /application\/vnd.google-apps.form/
puts "SKIP"

 $logging.log(ownername,"INFO","UPLOAD","#{title}/#{file_name}")
#$logging.push("<span style='red'>URI:#{title}</span> ")



elsif mime_type =~ /application\/vnd.google-apps.script/
puts "SKIP"

 $logging.log(ownername,"INFO","UPLOAD","#{title}/#{file_name}")
#$logging.push("<span style='red'>URI:#{title}</span> ")


elsif mime_type =~ /application\/vnd.google-apps.drive-sdk/
puts "SKIP"

 $logging.log(ownername,"INFO","UPLOAD","#{title}/#{file_name}")
#$logging.push("<span style='red'>URI:#{title}</span> ")


elsif mime_type =~ /application\/vnd.google-apps/
  puts convertiable[mime_type]
  puts "Y"
  insert_file(title, description, convertiable[mime_type], file_name, true)
else
  puts mime_type
  puts "N"
  insert_file(title, description, mime_type, file_name, convert = false)
end


end


def insert_file(title, description, mime_type, file_name, convert = false)
  client = @file_owner.drive_client
  drive = client.discovered_api('drive', 'v2')
  file = drive.files.insert.request_schema.new({
    'title' => title,
    'description' => description,
    'mimeType' => mime_type
  })
  # Set the parent folder.
  #if parent_id
  #  file.parents = [{'id' => parent_id}]
  #end
  media = Google::APIClient::UploadIO.new(file_name, mime_type)
  result = client.execute(
    :api_method => drive.files.insert,
    :body_object => file,
    :media => media,
    :parameters => {
      'uploadType' => 'multipart',
      'alt' => 'json',
      'convert' => convert})
  if result.status == 200
    return result.data
  else
    puts "An error occurred: #{result.data['error']['message']}"
    return nil
  end
end

####

def copy_file(origin_file_id, copy_title)
  client = @file_owner.drive_client
  drive = client.discovered_api('drive', 'v2')
  copied_file = drive.files.copy.request_schema.new({
    'title' => copy_title
  })
  result = client.execute(
    :api_method => drive.files.copy,
    :body_object => copied_file,
    :parameters => { 'fileId' => origin_file_id,
      'convert' => true


     })
  if result.status == 200
    return result.data
  else
    puts "An error occurred: #{result.data['error']['message']}"
  end
end

###

def delete_file(file_id)
  client = @file_owner.drive_client
  drive = client.discovered_api('drive', 'v2')
  result = client.execute(
    :api_method => drive.files.delete,
    :parameters => { 'fileId' => file_id })

  if result.status != 204
    puts "An error occurred: #{result.data['error']['message']}"
  end
end


def share(value, role)
  client = @file_owner.drive_client
  file_id = id
  drive = client.discovered_api('drive', 'v2')
  new_permission = drive.permissions.insert.request_schema.new({
    'value' => value,
    'type' => 'user',
    'role' => role
  })
  result = client.execute(
    :api_method => drive.permissions.insert,
    :body_object => new_permission,

    :parameters => { 'fileId' => file_id ,
    :sendNotificationEmails => false 
    }
    )
  if result.status == 200
    return result.data
  else
    puts "An error occurred: #{result.data['error']['message']}"
  end
end


def sharelist()
client = @file_owner.drive_client
  file_id = id


  drive = client.discovered_api('drive', 'v2')
  api_result = client.execute(
    :api_method => drive.permissions.list,
    :parameters => { 'fileId' => file_id })
  if api_result.status == 200
    permissions = api_result.data
    return permissions.items
  else
    puts "An error occurred: #{result.data['error']['message']}"
  end
end


def shareid(emailaddress)

  list = sharelist()
  newlist= {}
  list.each do |item|
    newlist[ item["emailAddress"] ] = item["id"]
  end
newlist[emailaddress]


end


def shareid2(emailaddress)
  client = @file_owner.drive_client

  drive = client.discovered_api('drive', 'v2')

pp drive.permissions.discovered_methods

  result = client.execute(
    :api_method => drive.permissions.getIdForEmail,
    :parameters => {
      'email' => emailaddress,
    })
  if result.status == 200
    permissionId = result.data
    puts "ID: #{permission.id}"
  else
    puts "An error occurred: #{result.data['error']['message']}"
  end
end



def remove_permission(emailaddress)
  client = @file_owner.drive_client
  file_id = id
  permission_id = shareid(emailaddress)

  drive = client.discovered_api('drive', 'v2')
  result = client.execute(
    :api_method => drive.permissions.delete,
    :parameters => {
      'fileId' => file_id,
      'permissionId' => permission_id })
  if result.status != 204
    #pp result.status
    puts "An error occurred:"
    pp result
  end
end



def copy(newtitle)
###
  client = @file_owner.drive_client
  file_id = id
  drive = client.discovered_api('drive', 'v2')

  copied_file = drive.files.copy.request_schema.new({
    'title' => newtitle
  })

  result = client.execute(
    :api_method => drive.files.copy,
    :body_object => copied_file,
    :parameters => { 'fileId' => file_id })
  if result.status == 200
    return result.data
  else
    puts "An error occurred: #{result.data['error']['message']}"
  end

###
end




end


