# MetaTrader 5 in docker container

Based on [wine-x11-novnc-docker](https://hub.docker.com/r/solarkennedy/wine-x11-novnc-docker) by [Kyle Anderson](https://github.com/solarkennedy)

## Usage
```bash
docker run --rm -p 8080:8080 itishermann/docker-mt5
```
Open your browser at http://localhost:8080 and voilà

## Nginx proxy
If you want to use it behind a proxy and use a basic pasword protection for remote access, take a look at [noVNC's Documentation](https://github.com/novnc/noVNC/wiki/Proxying-with-nginx)

if using this image

```
server {
    server_name <mt5.example.com>;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_http_version 1.1;
        proxy_set_header 	Upgrade			$http_upgrade;
        proxy_set_header 	Connection 		'upgrade';
        proxy_set_header 	Host			$host;
        proxy_cache_bypass 	$http_upgrade;
        proxy_set_header        X-Real-IP 		$remote_addr;
        proxy_set_header        X-Forwarded-For 	$proxy_add_x_forwarded_for;
        proxy_set_header        X-Forwarded-Proto	$scheme;
	      proxy_buffering 	off;
        proxy_read_timeout 61s;
    }

    listen 80;
}

```

## Contributing
For security concerns, everyone should bring his own MetaTrader 5 installation foler or installing it from the explorer 

```bash
# Mounts th mt5 setup file
docker run --rm -p 8080:8080 solarkennedy/wine-x11-novnc-docker -v mt5setup.exe:/root/mt5setup.exe
```

## TODO
- [ ] Reduce image size

