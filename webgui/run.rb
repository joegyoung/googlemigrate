pid = spawn 'rackup -p 5000  > /dev/null 2>&1'
Process.detach(pid) #tell the OS we're not interested in the exit status
