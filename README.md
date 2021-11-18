# EasyWebDav
Quick and easy to set up WebDav server on Linux Server

## Features
- Rapid Deployment
- Password protection
- No need to install any dependencies
- Uninstall without residue
- Customized directory
- Customized port

## TO DO
- Multi-user support

## Usage
### Install webdav-server
~~~shell
wget -O warp.sh https://cdn.jsdelivr.net/gh/missuo/EasyWebDav/webdav.sh && bash webdav.sh
~~~

### Configuring reverse proxy
~~~nginx
location / {
        proxy_pass http://127.0.0.1:2333;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header REMOTE-HOST $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $http_host;
        proxy_redirect off;
    }
~~~

## How to mount
### Mac
- Use Finder
![image](https://user-images.githubusercontent.com/55200481/142374705-cd29edec-9b01-4081-92e1-e9085697cbbd.png)

- [On Windows](https://blog.frankutils.xyz/archives/17/)


## Other Open-Source Code Used
[hacdias/webdav](https://github.com/hacdias/webdav)
Thanks to the above authors for the Go language version of webdav



