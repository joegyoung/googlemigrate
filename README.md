# Google Migration with Ruby
Migrate Google Docs to Local repository and back to Google

This project was created to download documents from Google Drive for A domain in a Google Apps Account. Then later, it would upload the documents back to Drive in a new Google Apps Account.

There are other methods to transfer files from Google Apps domain to another. These methods involve 3rd party companies and $3-$5 charge per user. I currently work within a School District with 7700 students and the cost to transfer thier documents would be in the range of $23,100 and $38,500. 

I have successfully used this code with the students account in my district. I pulled 107,222 files from Google that totaled 57gigs on the local drive. Remember that Google does not report the actually size of data stored on Google Drive because it does not report documents created in thier Google Docs format.  

## Details about code
Code consists of terminal scripts and a basic live feed web page .

## Installation
    % gem install bundler
    % bundle install
    % cd webgui 
    % bundle install
    % cd ../
    % cp config.yml-sample config.yml


### Additional information

- https://developers.google.com/drive/v2/reference/files/get
- https://github.com/google/google-api-ruby-client
