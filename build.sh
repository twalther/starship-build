#!/bin/bash

if [ -d "starship" ]; then
	cd starship
	git pull
	cd ..
else
	git clone https://github.com/starship/starship.git
fi

echo $(cat ./starship/Cargo.toml | grep version | head -1 | awk '{print $3}' | sed 's/"//g') > .version

docker build \
	-t starship-build \
	.

docker create \
	--name starship-build \
	starship-build

if ! [ -d "linux-target" ]; then
	mkdir linux-target
fi

docker cp \
	starship-build:/root/.cargo/bin/starship linux-target/starship

docker rm \
	starship-build

cd linux-target

chmod a+x starship

tar -cvzf starship-$(cat ../.version)-centos-7.6.1810.tar.gz starship

cp starship starship-$(cat ../.version)-centos-7.6.1810

cd ..
