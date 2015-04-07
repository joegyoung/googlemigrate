# Google Migration

Migrate Google Docs to Local repository and back to Google

This project was created to download documents from Google Drive for A domain in a Google Apps Account. Then later, it would upload the documents back to Drive in a new Google Apps Account.

There are other methods to transfer files from Google Apps domain to another. These methods involve 3rd party companies and $3-$5 charge per user. I currently work within a School District with 7700 students and the cost to transfer thier documents would be in the range of $23,100 and $38,500. 

I have successfully used this code with the students account in my district. I pulled 107,222 files from Google that totaled 57gigs on the local drive. Remember that Google does not report the actually size of data stored on Google Drive because it does not report documents created in thier Google Docs format. 

## Personal SVN server download
svn checkout "file:///Users/joeyoung/SYNC/SUBVERSION/Migrate"

### Mac setup 
xcode-select --install 

##Install Dependencies


    % gem install bundler
    % bundle install
    % gem install bundler
    % bundle install
    % cd webgui 
    % bundle install
    % cd ../
    % cp config.yml-sample config.yml

Edit config.yml

    % ---
    % savedirectory: "/Volume/Backup/Students"
    % googleshareuser: "googledrive@example.com"
    % enable_websocket: true
    %
    % googleapi:
    %   serviceaccountemail: '<tagcode>@developer.gserviceaccount.com'
    %   serviceaccountpkcs12filepath: 'oogleAPI.p12'
    %
    % website:
    %   host: googlemigrate.local




## Start Web GUI



## Import users from Google



## Run downloader

```
for i in {1..14}; do ruby MAIN-DOWNLOAD.rb -d -n log$i; done
for n in `ls pids/*log.txt`; do kill -9 `cat $n`; done;  rm pids/*
```




## Extra Reading URLs



- https://mail.google.com/
- https://www.googleapis.com/auth/admin.directory.user.readonly
- https://www.googleapis.com/auth/admin.directory.device.chromeos
- https://www.googleapis.com/auth/admin.directory.device.chromeos.readonly
- https://www.googleapis.com/auth/drive
- https://www.googleapis.com/auth/email.migration
- https://www.googleapis.com/auth/gmail.modify
- https://www.googleapis.com/auth/gmail.readonly
- https://www.googleapis.com/auth/admin.directory.orgunit




```
for n in `ruby Stats-mongo_docid.rb`; do echo -n "$n:  " ;ruby ./Classifiertest-test.rb $n;done > Classed.txt

for n in `ruby Stats-mongo_docid.rb`; do echo -n "$n:  " ;ruby Sentimental.rb $n;done
```