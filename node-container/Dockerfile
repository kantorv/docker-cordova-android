FROM ubuntu:14.04.3
MAINTAINER Valentin Kantor <kantorvv@gmail.com>

ENV DEBIAN_FRONTEND noninteractive
ENV USER root




# Set timezone AND locale (fix the locale warnings)
RUN locale-gen --purge en_US.UTF-8 && \
 	echo   'LANG="en_US.UTF-8"'  > /etc/default/locale  && \
	echo   'LANGUAGE="en_US:en"' >> /etc/default/locale && \
	echo "Asia/Jerusalem"  > /etc/timezone && \
	dpkg-reconfigure --frontend noninteractive tzdata



#####################################################
#############   Apt packages 	#####################  
#####################################################
RUN rm /etc/apt/sources.list
ADD stuff/sources.local.list /etc/apt/sources.list

RUN dpkg --add-architecture i386
RUN apt-get -y update
#installing software
#RUN apt-get -y install --fix-missing  supervisor  openssh-server curl   \
#									  default-jre openjdk-7-jdk ant \
#									  build-essential libc6 libc6-dev g++  g++-multilib \
#									  lib32z1 lib32ncurses5 lib32bz2-1.0 \
#									  nano mc multitail



RUN apt-get -y install libgl1-mesa-dev:i386 openjdk-7-jdk \
                        supervisor  openssh-server curl nano git



#####################################################
#############   Android SDK packages 	#############
#####################################################
RUN wget  http://dl.google.com/android/android-sdk_r24.4.1-linux.tgz && \
	tar xzvf android-sdk_r24.4.1-linux.tgz && \
    echo y  |   /android-sdk-linux/tools/android update sdk --all --filter tools,platform-tools,android-23,build-tools-23.0.3,addon-google_apis-google-23 --no-ui && \
    rm android-sdk_r24.4.1-linux.tgz

#android update sdk --all --filter tools,platform-tools,android-23,build-tools-23.0.3,addon-google_apis-google-23
RUN  echo y  | /android-sdk-linux/tools/android update sdk --no-ui --filter "extra"


#####################################################
#############   SSH configs 	#####################  
#####################################################
RUN mkdir /root/.ssh
RUN mkdir /var/run/sshd

ADD sshkey.pub /root/.ssh/authorized_keys
RUN chown root:root /root/.ssh/authorized_keys
RUN sed -i "s/UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config && sed -i "s/UsePAM.*/UsePAM no/g" /etc/ssh/sshd_config

 
RUN echo "export ANDROID_HOME=/android-sdk-linux" >> /root/.bashrc  && \
	echo 'export PATH=$PATH:$ANDROID_HOME/tools' >> /root/.bashrc  && \
	echo 'export PATH=$PATH:$ANDROID_HOME/platform-tools' >> /root/.bashrc && \
	echo 'export NODE_PATH=$NODE_PATH:/usr/local/lib/node_modules' >> /root/.bashrc





#####################################################
#############   NodeJS environment 	#################
#####################################################

RUN curl -sL https://deb.nodesource.com/setup | bash - && \
	apt-get install -y nodejs && \
	npm install -g n  && \
	n stable && \
	npm install -g npm

RUN npm install -g bower yo gulp generator-mobileangularui http-server cordova grunt npm-check-updates

#removing rootCheck function call, so we can work from root	
RUN sed -i "s/.*rootCheck.*//g" /usr/local/lib/node_modules/yo/lib/cli.js
ADD stuff/.bowerrc /root/.bowerrc

# update packages.json to lates versions
# npm outdated --json --depth=0 | jq --ascii-output --monochrome-output '. | keys | .[]' | xargs npm install $1 --save-dev




#########################################################################################
#############   Testing cordova app creation and building, 				  ###############
#############   just to make  sure all packackes are installed correctly  ###############  
#########################################################################################
ENV ANDROID_HOME /android-sdk-linux
ENV PATH=$PATH:/android-sdk-linux/tools:/android-sdk-linux/platform-tools


RUN mkdir /tmpdir && cd /tmpdir && \
	cordova create testApp && cd /tmpdir/testApp && \
	echo "testApp" | yo mobileangularui && \
	cordova platform add android && \
	cordova build android && cd / &&  \
	echo "removing temporary app..." && rm -rf /tmpdir


#####################################################
#############   Supervisor configs  	#############
#####################################################
RUN mkdir -p /var/log/supervisor
ADD stuff/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD stuff/bootstrap.sh /root/bootstrap.sh


EXPOSE 22 8001 8000 35729
CMD env | grep _ >> /etc/environment && /usr/bin/supervisord
