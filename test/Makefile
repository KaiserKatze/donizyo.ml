dockerfile=test-firewall.dockerfile
image_name=test-firewall
container_name=my-test-firewall
port_forward_src=18080
port_forward_dst=127.0.0.1:${port_forward_src}
port_forward=${port_forward_dst}:${port_forward_src}

test: run
	@echo -n "Testing network connection ... "
	@if curl -sL -m 1 http://${port_forward_dst}/; then echo "\e[32mSuccess\e[0m"; else echo "\e[31mFail\e[0m"; fi

build: preprocess
	@echo -n "Building docker image ... "
	docker build -t ${image_name} -f ${dockerfile} .

preprocess:
	sed -i "s/EXPOSE      8080/EXPOSE      ${port_forward_src}/g" ${dockerfile}
	sed -i "s/#define PORT_SERVER 8080/#define PORT_SERVER ${port_forward_src}/g" httpecho.c

run: clean build
	@echo "Starting docker container ... "
	docker run -dit -p ${port_forward} --name ${container_name} ${image_name}

clean:
	docker rm -f ${container_name} 2>/dev/null || true
	docker rmi -f ${docker images -f dangling=true -aq} 2>/dev/null || true
	docker images
