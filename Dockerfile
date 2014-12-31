FROM ubuntu:12.04

MAINTAINER Nat "nat.wrw@gmail.com"

RUN echo "deb http://mirror1.ku.ac.th/ubuntu/ precise main restricted universe" > /etc/apt/sources.list
RUN echo "deb http://mirror.kku.ac.th/ubuntu/ precise main restricted universe" >> /etc/apt/sources.list
RUN echo "deb http://mirror1.ku.ac.th/ubuntu/ precise-updates main restricted universe" >> /etc/apt/sources.list
RUN echo "deb http://mirror1.ku.ac.th/ubuntu/ precise-security main restricted universe" >> /etc/apt/sources.list
RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get upgrade  -y
RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y -q git autoconf build-essential gperf bison flex texinfo libtool libncurses5-dev wget apt-utils gawk sudo unzip libexpat-dev
RUN apt-get install -y vim bash-completion build-essential openssh-server
RUN useradd -d /opt/Espressif -m -s /bin/bash esp8266
RUN echo "esp8266 ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/esp8266
RUN chmod 0440 /etc/sudoers.d/esp8266
RUN su esp8266 -c "cd ~; git clone -b lx106 git://github.com/jcmvbkbc/crosstool-NG.git"
RUN su esp8266 -c "cd ~/crosstool-NG && ./bootstrap"
RUN su esp8266 -c "cd ~/crosstool-NG && ./configure --prefix=`pwd`"
RUN su esp8266 -c "cd ~/crosstool-NG && make"
RUN su esp8266 -c "cd ~/crosstool-NG && sudo make install"
RUN su esp8266 -c "cd ~/crosstool-NG && ./ct-ng xtensa-lx106-elf"
RUN su esp8266 -c "cd ~/crosstool-NG && ./ct-ng build"
RUN mv /opt/Espressif/crosstool-NG/builds/xtensa-lx106-elf /opt/Espressif/

#clear builds
RUN rm -rvf /opt/Espressif/crosstool-NG

#Symlink
#ADD symlink.sh /opt/Espressif/xtensa-lx106-elf/bin/
#RUN sh /opt/Espressif/xtensa-lx106-elf/bin/symlink.sh

RUN cd /opt/Espressif/xtensa-lx106-elf/bin && ln -sv xtensa-lx106-elf-addr2line xt-addr2line 
RUN cd /opt/Espressif/xtensa-lx106-elf/bin && ln -sv xtensa-lx106-elf-ar xt-ar 
RUN cd /opt/Espressif/xtensa-lx106-elf/bin && ln -sv xtensa-lx106-elf-as xt-as 
RUN cd /opt/Espressif/xtensa-lx106-elf/bin && ln -sv xtensa-lx106-elf-c++filt xt-c++filt 
RUN cd /opt/Espressif/xtensa-lx106-elf/bin && ln -sv xtensa-lx106-elf-gprof xt-gprof 
RUN cd /opt/Espressif/xtensa-lx106-elf/bin && ln -sv xtensa-lx106-elf-ld xt-ld 
RUN cd /opt/Espressif/xtensa-lx106-elf/bin && ln -sv xtensa-lx106-elf-nm xt-nm 
RUN cd /opt/Espressif/xtensa-lx106-elf/bin && ln -sv xtensa-lx106-elf-objcopy xt-objcopy 
RUN cd /opt/Espressif/xtensa-lx106-elf/bin && ln -sv xtensa-lx106-elf-objdump xt-objdump 
RUN cd /opt/Espressif/xtensa-lx106-elf/bin && ln -sv xtensa-lx106-elf-ranlib xt-ranlib 
RUN cd /opt/Espressif/xtensa-lx106-elf/bin && ln -sv xtensa-lx106-elf-readelf xt-readelf 
RUN cd /opt/Espressif/xtensa-lx106-elf/bin && ln -sv xtensa-lx106-elf-size xt-size 
RUN cd /opt/Espressif/xtensa-lx106-elf/bin && ln -sv xtensa-lx106-elf-strings xt-strings 
RUN cd /opt/Espressif/xtensa-lx106-elf/bin && ln -sv xtensa-lx106-elf-strip xt-strip 
RUN cd /opt/Espressif/xtensa-lx106-elf/bin && ln -sv xtensa-lx106-elf-cpp xt-xc++ 
RUN cd /opt/Espressif/xtensa-lx106-elf/bin && ln -sv xtensa-lx106-elf-gcc xt-xcc


#ESP8266 SDK

RUN su esp8266 -c "echo \"export PATH=/opt/Espressif/xtensa-lx106-elf/bin:$PATH\" >> ~/.profile"
RUN su esp8266 -c "cd ~ && wget -O esp_iot_sdk_v0.9.3_14_11_21.zip http://bbs.espressif.com/download/file.php?id=72"
RUN su esp8266 -c "cd ~ && wget -O esp_iot_sdk_v0.9.3_14_11_21_patch1.zip http://bbs.espressif.com/download/file.php?id=73"
RUN su esp8266 -c "cd ~ && unzip esp_iot_sdk_v0.9.3_14_11_21.zip"
RUN su esp8266 -c "cd ~ && unzip -o esp_iot_sdk_v0.9.3_14_11_21_patch1.zip"
RUN su esp8266 -c "cd ~ && mv esp_iot_sdk_v0.9.3 ESP8266_SDK_DOCKER"
RUN su esp8266 -c "cd ~ && mv License ESP8266_SDK_DOCKER/"
RUN su esp8266 -c "cd ~ && ls"
RUN su esp8266 -c "cd ~ && cd ESP8266_SDK_DOCKER"

#patch is not neccessary
RUN su esp8266 -c "cd ~/ESP8266_SDK_DOCKER/ && sed -i -e 's/xt-ar/xtensa-lx106-elf-ar/' -e 's/xt-xcc/xtensa-lx106-elf-gcc/' -e 's/xt-objcopy/xtensa-lx106-elf-objcopy/' Makefile"

RUN su esp8266 -c "cd ~/ESP8266_SDK_DOCKER/ && mv examples/IoT_Demo ."
RUN su esp8266 -c "cd ~/ESP8266_SDK_DOCKER && wget -O lib/libc.a https://github.com/esp8266/esp8266-wiki/raw/master/libs/libc.a"
RUN su esp8266 -c "cd ~/ESP8266_SDK_DOCKER && wget -O lib/libhal.a https://github.com/esp8266/esp8266-wiki/raw/master/libs/libhal.a"
RUN su esp8266 -c "cd ~/ESP8266_SDK_DOCKER && wget -O include.tgz https://github.com/esp8266/esp8266-wiki/raw/master/include.tgz"
RUN su esp8266 -c "cd ~/ESP8266_SDK_DOCKER && tar -xvzf include.tgz"
RUN su esp8266 -c "echo \"export PATH=/opt/Espressif/xtensa-lx106-elf/bin:$PATH\" > ~/ESP8266_SDK_DOCKER/env.sh"
RUN su esp8266 -c "export PATH=/opt/Espressif/xtensa-lx106-elf/bin:$PATH; cd ~/ESP8266_SDK_DOCKER; make clean; make"
RUN su -c "cd /opt/Espressif/ESP8266_SDK_DOCKER; git clone https://github.com/tommie/esptool-ck.git; cd esptool-ck; make; cp -Rv esptool /usr/bin/"

# add ssh server
RUN mkdir /var/run/sshd
RUN echo 'esp8266:esp8266' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]

#RUN su esp8266 -c "export PATH=/opt/Espressif/crosstool-NG/builds/xtensa-lx106-elf/bin:$PATH; cd ~/ESP8266_SDK_DOCKER && make clean; make"
#RUN su esp8266 -c "mkdir ~/ESP8266_SDK_DOCKER"
#RUN su esp8266 -c "wget -q http://filez.zoobab.com/esp8266/esptool-0.0.2.zip -O ~/ESP8266_SDK_DOCKER/esptool-0.0.2.zip"
#RUN su esp8266 -c "cd ~/ESP8266_SDK_DOCKER; unzip esptool-0.0.2.zip"
#RUN su esp8266 -c "cd ~/ESP8266_SDK_DOCKER/esptool; sed -i 's/WINDOWS/LINUX/g' Makefile; make"
RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get upgrade  -y
