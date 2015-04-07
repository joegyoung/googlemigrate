class GoogleAPI
  #attr_accessor :SERVICE_ACCOUNT_EMAIL, :SERVICE_ACCOUNT_PKCS12_FILE_PATH, :API_VERSION
  def initialize(user_email)
    @USER_EMAIL = user_email
    @SERVICE_ACCOUNT_EMAIL = $configuration["googleapi"]["serviceaccountemail"]
    ## Path to the Service Account's Private Key file #
    @SERVICE_ACCOUNT_PKCS12_FILE_PATH = File.dirname(__FILE__) +  '/../../certs/' + $configuration["googleapi"]["serviceaccountpkcs12filepath"]
    @API_VERSION = 'v2'
    @ownerinfo = get_info


    #@API = 'https://www.googleapis.com/auth/drive'
    #@API = 'https://mail.google.com/'
    #@API = 'https://www.googleapis.com/auth/admin.directory.user.readonly'
    self
  end

  def build_client(user_email,api)
    key = Google::APIClient::PKCS12.load_key(@SERVICE_ACCOUNT_PKCS12_FILE_PATH, 'notasecret')
    asserter = Google::APIClient::JWTAsserter.new(@SERVICE_ACCOUNT_EMAIL,
        api, key)
    client = Google::APIClient.new(
      :application_name => 'Example Ruby application',
      :application_version => '1.0.0'
      )
    begin
    client.authorization = asserter.authorize(user_email)
    client
    rescue
              $logging.push("<span style='red'>ERROR - Cant authorize #{user_email}</span>")
              puts "@@@@@ i was not able to authorize #{user_email}"
              $logging.log(user_email,"ERROR","AUTH"," Cant authorize #{user_email}")
              client = build_client(user_email,api)
              client
    end
  end
  

def list_users(domain,orgUnitPath = '/')
  orgUnitPath = orgUnitPath || "/" 
  client_id = 'https://www.googleapis.com/auth/admin.directory.user.readonly'
  client = build_client(@USER_EMAIL,client_id)
  api = client.discovered_api("admin", "directory_v1")

  #puts api.users.list.parameters

  returnabledata = Array.new;
  round = 0
  pageToken = ''
  begin
    #puts "Round: #{round}"
    round += 1
    #puts "pageToken: #{pageToken}"

    result = client.execute(
      :api_method => api.users.list,
      :parameters => { 'domain' => domain,
          'orderBy' => 'givenName',
        'maxResults' => 200,
        'pageToken'=> pageToken,
        #'fields' => 'users(id,etag,primaryEmail,name,suspended)',
        'fields' => 'nextPageToken,users(primaryEmail,suspended)',
        'query' => "orgUnitPath=#{orgUnitPath}"
      }
    )
    #pp result
    result.data.users.each do |user|
      if user["suspended"] == false
        returnabledata << user["primaryEmail"]
      end
    end
    pageToken = result.data["nextPageToken"]
    #puts "Count: #{result.data.users.count()}"
    $stdout.sync = true
    print "."
  end while  result.data['nextPageToken'].present?
  $stdout.sync = false
  print "\n"
  returnabledata
end 
##
##
##
def list_orgs
  client_id = 'https://www.googleapis.com/auth/admin.directory.user.readonly'
    client = build_client(@USER_EMAIL,client_id)
    api = client.discovered_api("admin", "directory_v1")

   result = client.execute(
        :api_method => api.orgunits.list,
        :parameters => { 'customerId' => "my_customer",
        }
      )
  pp result.data

end
##
##
##
def get_email(client, emailrecord)
  api = client.discovered_api("gmail", "v1")
  result = client.execute(
    :api_method => api.users.messages.get,
    :parameters => { 
      'userId' => "me",
      'id'=> emailrecord}
    )
  result.data
end
##
##
##


def makeAdmin
  client_id = 'https://www.googleapis.com/auth/admin.directory.user'
    client = build_client(@USER_EMAIL,client_id)
    api = client.discovered_api("admin", "directory_v1")

   result = client.execute(
        :api_method => api.users.makeAdmin,
        :parameters => { 'userKey' => "<emailaddress>",
        }
      )
  pp result.data

end



##
##
##




def total
  count
end

def emailcount
      client_id = 'https://mail.google.com/'
      client = build_client(@USER_EMAIL,client_id)
      api = client.discovered_api("gmail", "v1")
    begin
      result = client.execute(
        :api_method => api.users.messages.list,
        :parameters => { 
          'userId' => "me",
          }
        )
      result.data.resultSizeEstimate
    end
end


##
##
##




def email(emailrecord)

      client_id = 'https://mail.google.com/'
      client = build_client(@USER_EMAIL,client_id)
      email = get_email(client, emailrecord)

      if email.payload.parts.count == 2
          data =  email.payload.parts[0]['body']['data']
          message = data

        else
          data =  email.payload['body']['data']
          #message = Base64.urlsafe_decode64(data.encode("us-ascii"))
          message = Base64.decode64(data)
        end


        [ emailrecord, email.snippet, message ]



end
##
##
##
    def list_emails(amount="20")
      client_id = 'https://mail.google.com/'
      client = build_client(@USER_EMAIL,client_id)
      api = client.discovered_api("gmail", "v1")

      returnabledata = Array.new;
      returnableemails = Array.new;
      round = 0
      pageToken = ''
      begin
      #puts "Round: #{round}"
      round += 1
      #puts "pageToken: #{pageToken}"
      result = client.execute(
        :api_method => api.users.messages.list,
        :parameters => { 
          'userId' => "me",
          'pageToken'=> pageToken}
        )
      #puts result.data.to_hash
      result.data.messages.each do |message|
        returnabledata << message
      end
      pageToken = result.data["nextPageToken"]
      end while  result.data['nextPageToken'].present?
      #@CLIENT = client
      returnabledata.first(amount).each do |emailrecord|
        #pp emailrecord.id
        email =  get_email(client,emailrecord.id)
        
        if email.payload.parts.count == 2
          data =  email.payload.parts[0]['body']['data']
          message = data

        else
         # data =  email.payload['body']['data']
          #message = Base64.urlsafe_decode64(data.encode("us-ascii"))
          message = ""
        end


        returnableemails.push([ emailrecord.id, email.snippet, message ])
      end
      returnableemails 
    end 
##
##
##
    def info
      @ownerinfo
    end
##
##
##
    def ownername
      @ownerinfo.primaryEmail
    end
##
##
##
    def get_info
      client_id = 'https://www.googleapis.com/auth/admin.directory.user.readonly'
      client = build_client(@USER_EMAIL,client_id)
      api = client.discovered_api("admin", "directory_v1")
    result = client.execute(
        :api_method => api.users.get,
        :parameters => { 
          'userKey' => @USER_EMAIL,
          'viewType' => "domain_public"
          }
        )

      result.data
    end
##
##
##
    def drive_client
      client_id = 'https://www.googleapis.com/auth/drive'
      client = build_client(@USER_EMAIL,client_id)
      #client.discovered_api('drive', 'v2')
    end

##
##
##
  def list_files(q="")
    client_id = 'https://www.googleapis.com/auth/drive'
      client = build_client(@USER_EMAIL,client_id)
      drive = client.discovered_api('drive', 'v2')
      result = Array.new
      page_token = nil
      begin
        parameters = {'q'=> q}
        if page_token.to_s != ''
          parameters['pageToken'] = page_token
        end
        #puts "Check.. #{page_token}"
        api_result = client.execute(
          :api_method => drive.files.list,
          :parameters => parameters
         )
         #puts "--> #{api_result.data['nextPageToken']}"
        if api_result.status == 200

          files = api_result.data
          result.concat(files.items)
          page_token = files['nextPageToken']
        else
          puts "An error occurred: #{api_result.data['error']['message']}"
          page_token = nil
        end
      end while page_token.to_s != ''
        result
  end

##
##
##

  def filecount(q="")
    #list_files(q + " and mimeType != 'application/vnd.google-apps.folder'").count
    list_files(q ).count
  end

##
##
##
    def retrieve_files(q ="")
      result = list_files(q) 
      total = result.count
      if total > 0
          done = 1      
          result.each do |file_record|
            #pp file_record.id
            file = GoogleFileAPI.new([self,file_record])
             #pp file
            # puts "##"
             #puts file.ownername
             #puts file.title
             #puts file.details.id
             #puts file.show_links
             #file.show_link()
            print "[#{done}/#{total}]"
            done += 1
            file.show_link(true)
          end
      else
        puts "@@@@@ #{ownername} - There is nothing here"
      end

      googletotal = filecount(q)
      mytotal = $logging.file_counttotalforuser(ownername)


      if mytotal >= googletotal


            puts "SUCCESS [#{ownername}] I have all files [L:#{mytotal}/W:#{googletotal}]"
            $logging.push("SUCCESS [#{ownername}] I have all files [L:#{mytotal}/W:#{googletotal}]")
            $logging.log(ownername,"INFO","DONE","SUCCESS - I have all files [L:#{mytotal}/W:#{googletotal}]")

      else
            puts "FAIL [#{ownername}] I missing files [L:#{mytotal}/W:#{googletotal}]"
            $logging.push("FAIL [#{ownername}] I missing files [L:#{mytotal}/W:#{googletotal}]")
            $logging.log(ownername,"WARN","DONE","FAIL - I missing files [[L:#{mytotal}/W:#{googletotal}]")

      end


    end
end



